--SORGU2:Enerji İndiriminin Müşteri Tutmaya Etkisi

USE VeriProje;
GO

--TAHMİNİ ENERJİ İNDİRİMİNDEKİ fiyatları aralığını bulmak için min-max-avg kullan
Select  MAX(Tahmini_Enerji_Indirimi) AS En_Yüksek_İndirim,
        Min(Tahmini_Enerji_Indirimi) AS En_Düşük_İndirim,
        AVG(Tahmini_Enerji_Indirimi) AS Ort_İndirim,
        COUNT(CASE WHEN Tahmini_Enerji_Indirimi = 0 THEN 1 END) AS Hic_Indirim_Almayan_Kisi_Sayisi,
        COUNT(CASE WHEN Tahmini_Enerji_Indirimi > 0 THEN 1 END) AS Indirim_Alan_Kisi_Sayisi
From vw_Final_Churn_Analizi ;

select * From  vw_Final_Churn_Analizi ;

--arslığı daha net youmlamak için 
/* Düşük/Standart İndirim Alanlar: 0 < Tahmini_Enerji_Indirimi <= 200 (Ortalama olan 9.6'yı ve etrafını kapsar).
Yüksek İndirim Alanlar: Tahmini_Enerji_Indirimi > 200 (300'e kadar giden VIP veya özel müşterileri ayırır).
*/

SELECT  CASE When Tahmini_Enerji_Indirimi=0 Then '1-Hiç İndirim Almayanlar'
             WHEN  Tahmini_Enerji_Indirimi > 0 AND Tahmini_Enerji_Indirimi<=200 Then '2-Standart İndirim Alanlar'
             Else  '3-Yüksek İndirim Alanlar'
        END AS İndirim_segmenti,
         
       COUNT(DISTINCT Musteri_ID) AS Toplam_Musteri,
       COUNT(DISTINCT CASE WHEN Churn_Durumu = 1 THEN Musteri_ID END) AS Ayrılan_Musteri,
        
       CAST((COUNT(DISTINCT CASE WHEN Churn_Durumu = 1 THEN Musteri_ID END) * 100.0) 
         / COUNT(DISTINCT Musteri_ID) AS DECIMAL(5,2)) AS Churn_Orani_Yuzde
From vw_Final_Churn_Analizi 
Group By  
        CASE When Tahmini_Enerji_Indirimi=0 Then '1-Hiç İndirim Almayanlar'
             WHEN  Tahmini_Enerji_Indirimi > 0 AND Tahmini_Enerji_Indirimi <= 200 Then '2-Standart İndirim Alanlar'
             Else  '3-Yüksek İndirim Alanlar'
        END 
Order By İndirim_segmenti;
