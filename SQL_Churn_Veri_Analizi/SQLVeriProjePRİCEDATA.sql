USE VeriProje;
GO

-- 1. Varsa eski (hatalı) view'u veritabanından temizle
IF OBJECT_ID('vw_Master_Price_Data', 'V') IS NOT NULL
    DROP VIEW vw_Master_Price_Data;
GO

-- 2. Yeni ve güncel isimlerle (Musteri_ID vb.) view'u tertemiz oluştur
CREATE VIEW vw_Master_Price_Data AS
SELECT 
    id AS Musteri_ID,
    CONVERT(VARCHAR(10), CAST(price_date AS DATE), 104) AS ucret_tarihi,
    
    -- Tüketim Ücretleri
    COALESCE(CAST(price_off_peak_var AS FLOAT), 0) AS Yogun_olmayan_saatteki_ucret,
    COALESCE(CAST(price_peak_var AS FLOAT), 0) AS Yogun_saatteki_ucret,
    COALESCE(CAST(price_mid_peak_var AS FLOAT), 0) AS Orta_Yogun_saatteki_ucret,
    
    -- Sabit (SBT) Ücretler
    COALESCE(CAST(price_off_peak_fix AS FLOAT), 0) AS Yogun_olmayan_saatteki_SBT_ucret,
    COALESCE(CAST(price_peak_fix AS FLOAT), 0) AS Yogun_saatteki_SBT_ucret,
    COALESCE(CAST(price_mid_peak_fix AS FLOAT), 0) AS Orta_Yogun_saatteki_SBT_ucret

FROM [VeriProje].[dbo].[price_data];
GO

-- 3. İşlem bittikten sonra sonucu kontrol et
SELECT TOP 100 * FROM vw_Master_Price_Data;
 