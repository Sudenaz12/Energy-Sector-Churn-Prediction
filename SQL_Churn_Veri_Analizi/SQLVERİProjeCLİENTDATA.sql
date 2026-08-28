
Use  VeriProje;
Go

ALTER VIEW vw_Master_ClientData AS
SELECT 
    id AS Musteri_ID,
    
    CASE 
        WHEN channel_sales = 'MISSING' THEN 'Bilinmiyor'
        WHEN channel_sales = 'foosdfpfkusacimwkcsosbicdxkicaua' THEN 'Kanal A'
        WHEN channel_sales = 'lmkebamcaaclubfxadlmueccxoimlema' THEN 'Kanal B'
        WHEN channel_sales = 'usilxuppasemubllopkaafesmlibmsdf' THEN 'Kanal C'
        WHEN channel_sales = 'ewpakwlliwisiwduibdlfmalxowmwpci' THEN 'Kanal D'
        ELSE 'Diger Kanal'
    END AS Satis_Kanali,

    CASE 
        WHEN origin_up = 'lxidpiddsbxsbosboudacockeimpuepw' THEN 'Kampanya 1'
        WHEN origin_up = 'kamkkxfxxuwbdslkwifmmcsiusiuosws' THEN 'Kampanya 2'
        WHEN origin_up = 'ldkssxwpmemidmecebumciepwecameho' THEN 'Kampanya 3'
        ELSE 'Diger Kampanya'
    END AS Kaynak_Kampanya,

    -- Tüketim Verileri (Taşma olmaması için tamamı FLOAT)
    COALESCE(CAST(cons_12m AS FLOAT), 0) AS Elektrik_Tuketimi_12Ay,
    COALESCE(CAST(cons_gas_12m AS FLOAT), 0) AS Gaz_Tuketimi_12Ay,
    COALESCE(CAST(imp_cons AS FLOAT), 0) AS Odenen_Tuketim,
    
    -- Finansal Veriler (Taşma olmaması için tamamı FLOAT)
    COALESCE(CAST(margin_gross_pow_ele AS FLOAT), 0) AS Brut_Kar_Marji,
    COALESCE(CAST(margin_net_pow_ele AS FLOAT), 0) AS Net_Kar_Marji,
    COALESCE(CAST(net_margin AS FLOAT), 0) AS Toplam_Net_Marj,
    COALESCE(CAST(pow_max AS FLOAT), 0) AS Abone_Gucu_Max_KW,

    -- Tarih Verileri 
    CONVERT(VARCHAR(10), CAST(date_activ AS DATE), 104) AS Baslangic_Tarihi,
    CONVERT(VARCHAR(10), CAST(date_end AS DATE), 104) AS Bitis_Tarihi,
    CONVERT(VARCHAR(10), CAST(date_modif_prod AS DATE), 104) AS Urun_Degisiklik_Tarihi,
    CONVERT(VARCHAR(10), CAST(date_renewal AS DATE), 104) AS Sozlesme_Yenileme_Tarihi,

    -- Tahmin Verileri (Taşma olmaması için tamamı FLOAT)
    COALESCE(CAST(forecast_cons_12m AS FLOAT), 0) AS Tahmini_Tuketim_12Ay,
    COALESCE(CAST(forecast_discount_energy AS FLOAT), 0) AS Tahmini_Enerji_İndirimi,
    COALESCE(CAST(forecast_price_energy_off_peak AS FLOAT), 0) AS YogunOlmayanSaat_Tahmini_Elektrik_Fiyati_KW,
    COALESCE(CAST(forecast_price_energy_peak AS FLOAT), 0) AS YogunSaat_Tahmini_Elektrik_Fiyati_KW,
    COALESCE(CAST(forecast_price_pow_off_peak AS FLOAT), 0) AS YogunOlmayanSaat_Tahmini_Guc_Bedeli_KW,
    COALESCE(CAST(forecast_meter_rent_12m AS FLOAT), 0) AS Tahmini_12Aylik_Sayac_Kirasi,
    COALESCE(CAST(forecast_cons_year AS FLOAT), 0) AS Tahmini_Tuketim_Yillik,

    --  Binary ve Hedef Değişkenler
    CAST(has_gas AS INT) AS Dogalgaz_Abonesi_Mi,
    CAST(churn AS INT) AS Churn_Durumu
FROM [VeriProje].[dbo].[client_data];
GO

Select * FROM vw_Master_ClientData;

 
