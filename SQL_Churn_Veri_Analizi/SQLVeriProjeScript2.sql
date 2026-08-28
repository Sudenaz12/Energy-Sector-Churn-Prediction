USE VeriProje;
GO

--modelin tahmin etmesi için yeni müşteriler ekleme
Insert into [VeriProje].[dbo].[client_data] (
     id, channel_sales, origin_up, cons_12m, cons_gas_12m, imp_cons, 
    margin_gross_pow_ele, margin_net_pow_ele, net_margin, pow_max, 
    date_activ, date_end, date_modif_prod, date_renewal, 
    forecast_cons_12m, forecast_discount_energy, forecast_price_energy_off_peak, 
    forecast_price_energy_peak, forecast_price_pow_off_peak, forecast_meter_rent_12m, 
    forecast_cons_year, has_gas, churn)

Values 
 --  Yüksek tüketim + gaz yok + churn yok
(
    'NEW_CLIENT_001',
    'lmkebamcaaclubfxadlmueccxoimlema', 'kamkkxfxxuwbdslkwifmmcsiusiuosws',
    25000,0,18000,2500,1800,3200,12.5,
    '2025-01-15','2027-01-15','2025-01-15','2026-01-15',
    26000,0.095,0.120,0.085,120,22000, 0,0
),
 
  -- Düşük tüketim + gaz yok + churn
   
(  'NEW_CLIENT_002',
   'ewpakwlliwisiwduibdlfmalxowmwpci', 'ldkssxwpmemidmecebumciepwecameho',
   3500,0,2500,900,650,700,4.5,
   '2025-03-10','2026-03-10','2025-03-10','2026-03-10',
   4000,5,0.110,0.140,0.095,80,3200,0,1
),

    --Yüksek tüketim + DOĞALGAZ + churn yok

(
    'NEW_CLIENT_003','foosdfpfkusacimwkcsosbicdxkicaua', 'MISSING',
    50000,30000,42000,4500,3500,6000,18.5,
    '2024-06-20','2027-06-20','2025-06-20','2026-06-20',
    52000,10,0.090,0.115,0.080,150,48000,1,0
),
--   Orta tüketim + DOĞALGAZ + yüksek indirim + churn
(
    'NEW_CLIENT_004','lmkebamcaaclubfxadlmueccxoimlema', 'lxidpiddsbxsbosboudacockeimpuepw',
    12000,8000,10000,1800,1200, 1900,8.5,
    '2025-05-05','2026-05-05','2025-05-05','2026-05-05',
    13000,25,0.080,0.105,0.070,100,11500, 1, 1
);

GO

INSERT INTO [VeriProje].[dbo].[price_data] (
    id, price_date, price_off_peak_var, price_peak_var, price_mid_peak_var, 
    price_off_peak_fix, price_peak_fix, price_mid_peak_fix
)
VALUES 
('NEW_CLIENT_001', '2025-01-15', 0.095, 0.120, 0.110, 40, 50, 45),

('NEW_CLIENT_002', '2025-03-10', 0.110, 0.140, 0.125, 35, 45, 40),

('NEW_CLIENT_003', '2024-06-20', 0.090, 0.115, 0.105, 45, 55, 50),

('NEW_CLIENT_004', '2025-05-05', 0.080, 0.105, 0.095, 30, 40, 35);
GO