USE VeriProje;
GO

-- 1. Önce çakışma olmaması için eski TEST verilerini temizleyelim
DELETE FROM [VeriProje].[dbo].[price_data] WHERE id LIKE 'TEST_99%';
DELETE FROM [VeriProje].[dbo].[client_data] WHERE id LIKE 'TEST_99%';
GO

-- 2. TEST_9901 ile TEST_9906 Arasındaki Tüm Müşterileri Ekleme
INSERT INTO [VeriProje].[dbo].[client_data] (
    id, channel_sales, origin_up, cons_12m, cons_gas_12m, imp_cons, 
    margin_gross_pow_ele, margin_net_pow_ele, net_margin, pow_max, 
    date_activ, date_end, date_modif_prod, date_renewal, 
    forecast_cons_12m, forecast_discount_energy, forecast_price_energy_off_peak, 
    forecast_price_energy_peak, forecast_price_pow_off_peak, forecast_meter_rent_12m, 
    forecast_cons_year, has_gas, churn
) 
VALUES 
 
('TEST_9901', 'lmkebamcaaclubfxadlmueccxoimlema', 'lxidpiddsbxsbosboudacockeimpuepw', 4500.0, 1200.0, 3800.0, 
 1000.0, 5.20, 15.0, 11.5, 
 '2023-01-01', '2024-01-01', '2023-01-01', '2023-06-01', 
 298000.0, 0.0, 0.15, 
 0.20, 40.0, 67.0, 
 4500.0, 1, 0),  

 
('TEST_9902', 'foosdfpfkusacimwkcsosbicdxkicaua', 'MISSING', 2100.0, 800.0, 2100.0, 
 5450.0, 45.50, 60.0, 8.0, 
 '2020-01-01', '2024-01-01', '2020-01-01', '2023-01-01', 
 20540.0, 150.0, 0.10, 
 0.15, 35.0, 45.0, 
 214400.0, 1, 0), 

 
('TEST_9903', 'ewpakwlliwisiwduibdlfmalxowmwpci', 'ldkssxwpmemidmecebumciepwecameho', 3300.0, 300.0, 300.0, 
 3809.0, 25.10, 30.0, 27.5, 
 '2022-06-17', '2024-01-01', '2023-06-17', '2024-11-19', 
 234000.0, 50.0, 0.01, 
 0.30, 15.0, 5.0, 
 56400.0, 0, 0), 

--  
('TEST_9904', 'lmkebamcaaclubfxadlmueccxoimlema', 'kamkkxfxxuwbdslkwifmmcsiusiuosws', 3300.0, 3000.0, 4000.0, 
 2349.0, 15.10, 20.0, 18.0, 
 '2023-04-11', '2024-01-01', '2023-04-11', '2024-02-13', 
 224500.0, 27.50, 0.21, 
 0.25, 10.0, 19.0, 
 1600.0, 1, 0),

--   Yüksek tüketimli, orijinal büyük ölçekli
('TEST_9905', 'foosdfpfkusacimwkcsosbicdxkicaua', 'MISSING', 14500000.0, 4800000.0, 1250000.0, 
 1450.0, 520.0, 2450.0, 120.0, 
 '2017-02-10', '2026-01-01', '2022-01-01', '2023-01-01', 
 13800000.0, 0.0, 0.18, 
 0.22, 50.0, 45.0, 
 14000000.0, 1, 0),  

--  Yüksek tüketimli, orijinal büyük ölçekli
('TEST_9906', 'lmkebamcaaclubfxadlmueccxoimlema', 'Kampanya 1', 28500000.0, 9500000.0, 3100000.0, 
 9200.0, 31000.0, 75000.0, 250.0, 
 '2015-06-15', '2028-01-01', '2021-06-01', '2024-01-01', 
 27000000.0, 350.0, 0.11, 
 0.14, 25.0, 30.0, 
 27500000.0, 1, 0);
GO

-- 3. Tüm Bu Müşterilere Ait Fiyat Verilerini Ekleme
INSERT INTO [VeriProje].[dbo].[price_data] (
    id, price_date, price_off_peak_var, price_peak_var, price_mid_peak_var, 
    price_off_peak_fix, price_peak_fix, price_mid_peak_fix
) 
VALUES 
('TEST_9901', '2023-12-01', 0.18, 0.25, 0.20, 15.0, 25.0, 18.0),
('TEST_9902', '2023-12-01', 0.12, 0.19, 0.15, 10.0, 18.0, 12.0),
('TEST_9903', '2023-12-01', 0.34, 0.22, 0.17, 12.0, 10.0, 14.0),
('TEST_9904', '2023-12-01', 0.15, 0.20, 0.17, 20.0, 27.0, 22.0),
('TEST_9905', '2023-12-01', 0.20, 0.28, 0.23, 25.0, 35.0, 28.0),
('TEST_9906', '2023-12-01', 0.10, 0.15, 0.12, 10.0, 15.0, 12.0);
GO