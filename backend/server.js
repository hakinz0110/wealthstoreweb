const express = require('express');
const cors = require('cors');
const axios = require('axios');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Initialize Supabase
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Backend is running' });
});

// Paystack verification endpoint
app.post('/api/verify-payment/paystack', async (req, res) => {
  try {
    const { reference, orderId } = req.body;

    console.log(`Verifying Paystack payment: ${reference} for order: ${orderId}`);

    // Verify with Paystack
    const response = await axios.get(
      `https://api.paystack.co/transaction/verify/${reference}`,
      {
        headers: {
          'Authorization': `Bearer ${process.env.PAYSTACK_SECRET_KEY}`,
          'Content-Type': 'application/json',
        },
      }
    );

    console.log('Paystack response:', response.data);

    if (response.data.status === true && response.data.data.status === 'success') {
      // Update order in Supabase
      const { data, error } = await supabase
        .from('orders')
        .update({
          status: 'paid',
          payment_status: 'completed',
          transaction_id: reference,
          updated_at: new Date().toISOString(),
        })
        .eq('id', orderId)
        .select();

      if (error) {
        console.error('Database update error:', error);
        throw error;
      }

      console.log(`Order ${orderId} updated successfully`);

      res.json({
        success: true,
        message: 'Payment verified and order updated',
        amount: response.data.data.amount / 100,
        currency: response.data.data.currency,
        transactionId: reference,
      });
    } else {
      res.status(400).json({
        success: false,
        message: 'Payment verification failed',
        status: response.data.data?.status || 'unknown',
      });
    }
  } catch (error) {
    console.error('Verification error:', error.message);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// Verify payment endpoint
app.post('/api/verify-payment', async (req, res) => {
  try {
    const { transactionId, orderId } = req.body;

    console.log(`Verifying payment: ${transactionId} for order: ${orderId}`);

    // Verify with Flutterwave
    const response = await axios.get(
      `https://api.flutterwave.com/v3/transactions/${transactionId}/verify`,
      {
        headers: {
          'Authorization': `Bearer ${process.env.FLUTTERWAVE_SECRET_KEY}`,
          'Content-Type': 'application/json',
        },
      }
    );

    console.log('Flutterwave response:', response.data);

    if (response.data.status === 'success' && response.data.data.status === 'successful') {
      // Update order in Supabase
      const { data, error } = await supabase
        .from('orders')
        .update({
          status: 'paid',
          payment_status: 'completed',
          transaction_id: transactionId,
          updated_at: new Date().toISOString(),
        })
        .eq('id', orderId)
        .select();

      if (error) {
        console.error('Database update error:', error);
        throw error;
      }

      console.log(`Order ${orderId} updated successfully`);

      res.json({
        success: true,
        message: 'Payment verified and order updated',
        amount: response.data.data.amount,
        currency: response.data.data.currency,
        transactionId: transactionId,
      });
    } else {
      res.status(400).json({
        success: false,
        message: 'Payment verification failed',
        status: response.data.data?.status || 'unknown',
      });
    }
  } catch (error) {
    console.error('Verification error:', error.message);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// Paystack webhook endpoint
app.post('/api/webhook/paystack', async (req, res) => {
  try {
    // Verify webhook signature
    const hash = require('crypto')
      .createHmac('sha512', process.env.PAYSTACK_SECRET_KEY)
      .update(JSON.stringify(req.body))
      .digest('hex');

    if (hash !== req.headers['x-paystack-signature']) {
      console.error('Invalid webhook signature');
      return res.status(401).send('Unauthorized');
    }

    const payload = req.body;
    console.log('Paystack webhook received:', JSON.stringify(payload, null, 2));

    // Handle successful payment
    if (payload.event === 'charge.success') {
      const reference = payload.data.reference;
      const orderId = reference.split('_')[1]; // Extract order ID from reference

      console.log(`Processing payment for order: ${orderId}`);

      // Update order
      const { data, error } = await supabase
        .from('orders')
        .update({
          status: 'paid',
          payment_status: 'completed',
          transaction_id: reference,
          updated_at: new Date().toISOString(),
        })
        .eq('id', orderId)
        .select();

      if (error) {
        console.error('Database update error:', error);
        throw error;
      }

      console.log(`Order ${orderId} updated successfully:`, data);

      res.json({
        success: true,
        message: 'Webhook processed successfully',
        orderId: orderId,
      });
    } else if (payload.event === 'charge.failed') {
      const reference = payload.data.reference;
      const orderId = reference.split('_')[1];

      console.log(`Payment failed for order: ${orderId}`);

      await supabase
        .from('orders')
        .update({
          status: 'cancelled',
          payment_status: 'failed',
          updated_at: new Date().toISOString(),
        })
        .eq('id', orderId);

      res.send('Payment failed processed');
    } else {
      console.log('Webhook event acknowledged:', payload.event);
      res.send('OK');
    }
  } catch (error) {
    console.error('Webhook error:', error.message);
    res.status(500).json({ error: error.message });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`✅ Backend server running on port ${PORT}`);
  console.log(`📍 Health check: http://localhost:${PORT}/health`);
  console.log(`💳 Verify Paystack payment: http://localhost:${PORT}/api/verify-payment/paystack`);
  console.log(`🔔 Paystack Webhook: http://localhost:${PORT}/api/webhook/paystack`);
});
