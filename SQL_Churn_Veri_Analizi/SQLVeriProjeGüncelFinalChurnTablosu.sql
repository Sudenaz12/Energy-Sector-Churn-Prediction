USE VeriProje;
GO

IF OBJECT_ID('vw_Final_Churn_Analizi', 'V') IS NOT NULL
    DROP VIEW vw_Final_Churn_Analizi;
GO

CREATE VIEW vw_Final_Churn_Analizi AS 
WITH CTE_PriceData AS (
    -- Fiyat tablosundaki verileri müşteri bazında tekilleştiriyoruz
    SELECT 
        Musteri_ID,
        AVG(Yogun_olmayan_saatteki_ucret) AS Yogun_olmayan_saatteki_ucret,
        AVG(Yogun_saatteki_ucret) AS Yogun_saatteki_ucret,
        AVG(Orta_Yogun_saatteki_ucret) AS Orta_Yogun_saatteki_ucret,
        AVG(Yogun_olmayan_saatteki_SBT_ucret) AS Yogun_olmayan_saatteki_SBT_ucret,
        AVG(Yogun_saatteki_SBT_ucret) AS Yogun_saatteki_SBT_ucret,
        AVG(Orta_Yogun_saatteki_SBT_ucret) AS Orta_Yogun_saatteki_SBT_ucret
    FROM vw_Master_Price_Data
    GROUP BY Musteri_ID
),
CTE_ClientData AS (
    -- Müşteri tablosundaki olası mükerrer kayıtları ID bazında tekilleştiriyoruz
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Musteri_ID ORDER BY Baslangic_Tarihi DESC) AS SiraNo
    FROM vw_Master_ClientData
)
SELECT 
    c.Musteri_ID, c.Satis_Kanali, c.Kaynak_Kampanya, c.Elektrik_Tuketimi_12Ay, 
    c.Gaz_Tuketimi_12Ay, c.Odenen_Tuketim, c.Net_Kar_Marji, c.Baslangic_Tarihi, 
    c.Bitis_Tarihi, c.Churn_Durumu, c.Tahmini_Enerji_İndirimi, 
    c.Tahmini_Tuketim_12Ay, c.Abone_Gucu_Max_kW, c.Dogalgaz_Abonesi_Mi,

    -- ÖZELLİK 1: İndirim Segmenti
    CASE 
         WHEN c.Tahmini_Enerji_İndirimi = 0 THEN '1-Hiç İndirim Almayanlar'
         WHEN c.Tahmini_Enerji_İndirimi > 0 AND c.Tahmini_Enerji_İndirimi <= 200 THEN '2-Standart İndirim Alanlar'
         ELSE '3-Yüksek İndirim Alanlar'
    END AS Indirim_Segmenti,

    -- ÖZELLİK 2: Kapasite Segmenti
    CASE 
         WHEN c.Abone_Gucu_Max_kW > 50 AND c.Tahmini_Tuketim_12Ay < 10000 THEN '1- Atıl Kapasite'
         WHEN c.Abone_Gucu_Max_kW <= 50 AND c.Tahmini_Tuketim_12Ay < 10000 THEN '2- Küçük Tüketici'
         WHEN c.Tahmini_Tuketim_12Ay >= 10000 THEN '3- Büyük Tüketici'
         ELSE '4-Diğer Tüketici'
    END AS Musteri_Kapasite_Segmenti,

    -- ÖZELLİK 3: Enerji Profil Segmenti
    CASE 
         WHEN c.Dogalgaz_Abonesi_Mi = 0 AND c.Tahmini_Tuketim_12Ay > 10000 THEN '1- Sadece Elektrik - Yüksek Tüketici'
         WHEN c.Dogalgaz_Abonesi_Mi = 0 AND c.Tahmini_Tuketim_12Ay <= 10000 THEN '2- Sadece Elektrik - Standart Tüketici'
         WHEN c.Dogalgaz_Abonesi_Mi = 1 AND c.Tahmini_Tuketim_12Ay > 10000 THEN '3- Doğalgaz+Elektrik - Yüksek Tüketici'
         ELSE '4- Doğalgaz+Elektrik - Standart Tüketici'
    END AS Musteri_Profil_Segmenti,

    -- ÖZELLİK 4: Kampanya Tipi
    ISNULL(c.Kaynak_Kampanya, 'Kampanyasız Gelen') AS Kampanya_Tipi,
    
    p.Yogun_olmayan_saatteki_ucret, p.Yogun_saatteki_ucret, p.Orta_Yogun_saatteki_ucret,
    p.Yogun_olmayan_saatteki_SBT_ucret, p.Yogun_saatteki_SBT_ucret, p.Orta_Yogun_saatteki_SBT_ucret
FROM CTE_ClientData c
LEFT JOIN CTE_PriceData p ON c.Musteri_ID = p.Musteri_ID
WHERE c.SiraNo = 1;
GO


SELECT   * FROM vw_Final_Churn_Analizi;

SELECT 
    Musteri_ID, 
    Satis_Kanali, 
    Kampanya_Tipi, 
    Net_Kar_Marji, 
    Indirim_Segmenti, 
    Musteri_Profil_Segmenti 
FROM vw_Final_Churn_Analizi 
WHERE Musteri_ID IN ('TEST_9901','TEST_9902','TEST_9903','TEST_9904','TEST_9905','TEST_9906','NEW_CLIENT_001','NEW_CLIENT_002','NEW_CLIENT_003','NEW_CLIENT_004');

