import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const PAYSTACK_SECRET_KEY = Deno.env.get('PAYSTACK_SECRET_KEY')!
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { reference, orderId, expectedAmount, verifyOnly } = await req.json()

    // Validate required fields
    if (!reference) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          message: 'Missing required field: reference',
          status: 'invalid_request',
        }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Supabase client
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY)

    // If verifyOnly mode - just verify payment without order update
    if (verifyOnly) {
      console.log(`🔍 Verifying payment only (no order): ${reference}`)
    } else {
      // Standard mode - require orderId
      if (!orderId) {
        return new Response(
          JSON.stringify({ 
            success: false, 
            message: 'Missing required field: orderId',
            status: 'invalid_request',
          }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      console.log(`🔍 Verifying Paystack payment: ${reference} for order: ${orderId}`)
    }

    let existingOrder = null

    // Only check order if not in verifyOnly mode
    if (!verifyOnly && orderId) {
      const { data: orderData, error: orderCheckError } = await supabase
        .from('orders')
        .select('id, payment_status, transaction_id, total')
        .eq('id', orderId)
        .single()

      if (orderCheckError || !orderData) {
        console.error('Order not found:', orderCheckError)
        return new Response(
          JSON.stringify({ 
            success: false, 
            message: 'Order not found',
            status: 'order_not_found',
          }),
          { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      existingOrder = orderData

      // Prevent duplicate payment processing
      if (existingOrder.payment_status === 'completed' && existingOrder.transaction_id) {
        console.log(`⚠️ Order ${orderId} already paid with transaction: ${existingOrder.transaction_id}`)
        return new Response(
          JSON.stringify({ 
            success: true, 
            message: 'Payment already verified',
            status: 'already_paid',
            transactionId: existingOrder.transaction_id,
          }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
    }

    // Verify payment with Paystack API
    const paystackResponse = await fetch(
      `https://api.paystack.co/transaction/verify/${encodeURIComponent(reference)}`,
      {
        headers: {
          'Authorization': `Bearer ${PAYSTACK_SECRET_KEY}`,
          'Content-Type': 'application/json',
        },
      }
    )

    const paystackData = await paystackResponse.json()
    console.log('📦 Paystack API response:', JSON.stringify(paystackData, null, 2))

    // Check Paystack response status
    if (!paystackData.status) {
      console.error('❌ Paystack API error:', paystackData.message)
      return new Response(
        JSON.stringify({ 
          success: false, 
          message: paystackData.message || 'Paystack verification failed',
          status: 'paystack_error',
        }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const txData = paystackData.data
    const txStatus = txData?.status

    // Handle different transaction statuses
    // Paystack statuses: success, failed, abandoned, pending, processing, queued, reversed
    if (txStatus === 'success') {
      // Verify amount matches (prevent partial payment attacks)
      const paidAmountNaira = txData.amount / 100
      const expectedAmountNaira = expectedAmount || existingOrder?.total

      if (expectedAmountNaira && Math.abs(paidAmountNaira - expectedAmountNaira) > 1) {
        console.error(`❌ Amount mismatch! Paid: ${paidAmountNaira}, Expected: ${expectedAmountNaira}`)
        return new Response(
          JSON.stringify({ 
            success: false, 
            message: 'Payment amount does not match order total',
            status: 'amount_mismatch',
            paidAmount: paidAmountNaira,
            expectedAmount: expectedAmountNaira,
          }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // If verifyOnly mode - just return success without updating order
      if (verifyOnly) {
        console.log(`✅ Payment ${reference} verified (verifyOnly mode)`)
        return new Response(
          JSON.stringify({ 
            success: true, 
            message: 'Payment verified successfully',
            status: 'success',
            amount: paidAmountNaira,
            currency: txData.currency,
            channel: txData.channel,
            transactionId: reference,
            paidAt: txData.paid_at,
          }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Payment verified - update order
      const { error: updateError } = await supabase
        .from('orders')
        .update({
          status: 'confirmed',
          payment_status: 'completed',
          transaction_id: reference,
          payment_channel: txData.channel || 'unknown',
          payment_verified_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })
        .eq('id', orderId)

      if (updateError) {
        console.error('❌ Database update error:', updateError)
        throw updateError
      }

      console.log(`✅ Order ${orderId} payment verified and updated`)

      return new Response(
        JSON.stringify({ 
          success: true, 
          message: 'Payment verified successfully',
          status: 'success',
          amount: paidAmountNaira,
          currency: txData.currency,
          channel: txData.channel,
          transactionId: reference,
          paidAt: txData.paid_at,
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    } 
    
    // Payment not yet successful - return current status
    // This handles: pending, processing, queued, abandoned, failed, reversed
    console.log(`⏳ Payment status for ${reference}: ${txStatus}`)
    
    return new Response(
      JSON.stringify({ 
        success: false, 
        message: `Payment ${txStatus}`,
        status: txStatus || 'unknown',
        gatewayResponse: txData?.gateway_response,
      }),
      { 
        status: txStatus === 'pending' || txStatus === 'processing' ? 202 : 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('❌ Verification error:', error)
    return new Response(
      JSON.stringify({ 
        success: false,
        message: 'Internal server error during verification',
        status: 'server_error',
        error: error.message 
      }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
