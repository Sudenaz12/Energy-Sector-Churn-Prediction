--SORGU 3: Fiyat Değişimine Karşı Tüketim Psikolojisi
USE VeriProje;
GO

-- Şirketi terk edenler, yoğun (peak) saatlerde daha fazla tüketim yapıp daha yüksek birim fiyatlara maruz kaldıkları için mi ayrılıyor
--daha net okumak için where filtresi ile ücretleri<1000 sınırla çünü bunu asla geçemezler
SELECT 
    CASE WHEN Churn_Durumu = 1 THEN 'Ayrılan Müşteriler' ELSE 'Devam Eden Müşteriler' END AS Musteri_Durumu,
    COUNT(DISTINCT Musteri_ID) AS Kisi_sayisi,
    
    CAST(AVG(Yogun_saatteki_ücret) AS DECIMAL(18,2)) AS Ort_yogun_saat_ucreti,
    CAST(AVG(Yogun_olmayan_saattaki_ucret) AS DECIMAL(18,2)) AS Ort_yogun_olmayan_saat_ucreti,
    CAST(AVG(Elektrik_Tuketimi_12Ay) AS DECIMAL(18,2)) AS Ort_Yillik_Elektrik_Tuketimi
FROM vw_Final_Churn_Analizi
WHERE Yogun_saatteki_ücret < 1000000000 
  AND Yogun_olmayan_saattaki_ucret < 1000000000
  --fiyatın 1 milyardan küçük olduğu (yani gerçek ve mantıklı) satırları içeri al, devasa hatalı kayıtları alma 
GROUP BY Churn_Durumu;