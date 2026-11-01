# Misthanpur Online Shop — setup and publishing

This is a mobile-first React + Vite storefront for Misthanpur, configured with WhatsApp ordering and Supabase-backed products/orders/admin authentication.

## 1. Run locally

1. Install Node.js 20 or later.
2. In this folder run `npm install`.
3. Copy `.env.example` to `.env` and fill in your Supabase project URL and anon/publishable key.
4. Run `npm run dev` and open the local URL printed by Vite.

## 2. Create the Supabase backend

1. Create a project at https://supabase.com.
2. Open **SQL Editor**, paste all of `supabase.sql`, and run it.
3. In **Authentication → Providers → Phone**, enable Phone sign-in and configure an SMS provider supported by Supabase. Phone OTP requires an SMS provider; it is not automatically free/unlimited. For testing, use Supabase's configured test OTPs if available.
4. In **Authentication → URL Configuration**, add your Vercel deployment URL to the allowed redirect/site URLs.
5. Copy Project URL and anon/publishable key from **Project Settings → API** into `.env` (locally) and Vercel Environment Variables (production).
6. Deploy the app, then sign in once at `https://YOUR-APP.vercel.app/admin` using the shop administrator phone.
7. In Supabase SQL Editor, run the admin allowlist statement at the bottom of `supabase.sql`, replacing the phone if needed. The current configured phone is `+919801265197`. This step grants admin rights only to the matching authenticated user.

**Security:** Never put the Supabase `service_role` key in this frontend. Only the anon/publishable key belongs in `VITE_SUPABASE_ANON_KEY`. Keep the admin allowlist restricted to trusted people.

## 3. Deploy to Vercel

1. Push this folder to a private or public GitHub repository.
2. Sign in at https://vercel.com and choose **Add New → Project**, then import the repository.
3. Framework preset: **Vite**. Build command: `npm run build`. Output directory: `dist`.
4. Add environment variables:
   - `VITE_SUPABASE_URL` = your Supabase project URL
   - `VITE_SUPABASE_ANON_KEY` = your Supabase anon/publishable key
   - `VITE_WHATSAPP_NUMBER` = `919801265197`
   - `VITE_UPI_ID` = your verified shop UPI ID (optional)
   - `VITE_UPI_NAME` = `Misthanpur`
5. Deploy. Vercel will provide a free `*.vercel.app` URL.

A `vercel.json` rewrite is included so `/admin` works on refresh.

## 4. Before accepting real orders

- Replace sample products/prices and emoji art with actual menu, verified prices and real product photos from the admin panel.
- Add the correct UPI ID/QR only after verifying it belongs to the shop. The current payment area is informational and does not process payments.
- Confirm whether orders are pickup, delivery, or both; add delivery charges/minimum order if applicable.
- Test a complete order on a phone and verify it appears in Supabase and WhatsApp.
- Supabase free projects may pause after inactivity and have quotas/limits. Check current plan limits before relying on it for a busy shop.

## 5. Notes

- Customers do not need an account.
- Orders are saved to Supabase before WhatsApp opens. The customer must still tap **Send** in WhatsApp to send the message to the shop.
- If Supabase is not configured, the storefront shows sample preview items; admin login and database-backed orders/products will not work.
- The app uses Supabase realtime updates for product changes while the store is open.
