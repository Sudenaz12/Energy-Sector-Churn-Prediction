USE VeriProje;
GO
--sorgu 1:Satış Kanalına Göre Müşteri Kaybı (Churn) Analizi

--SATIS KANALLARINI TEKRARSIZ YAZDIR(dıstincount) ,sonra count ile hepsinde kaç müşteri olduğunu  dıstınctvsay ve group by ile satıs kanalına göre gruplandır
--AMA GROUP BY KULLANDIĞIM İÇİN DİSTİNCOUNT GEREK KALMAZ.sonra B->K sırala 
--churn 1 ayrılan,0 devam edenlerdir ,
--count ile her kanalın kendi içindeki müşteri kaybetme yüzdesini hesapla

Select  Satis_Kanali,
    COUNT(DISTINCT Musteri_ID) AS Toplam_Musteri,
    
   
    COUNT(DISTINCT CASE WHEN Churn_Durumu = 1 THEN Musteri_ID END) AS Ayrılan_Musteri,
    
    CAST((COUNT(DISTINCT CASE WHEN Churn_Durumu = 1 THEN Musteri_ID END) * 100.0) 
         / COUNT(DISTINCT Musteri_ID) AS DECIMAL(5,2)) AS Churn_Orani_Yuzde

From vw_Final_Churn_Analizi WHERE Satis_Kanali IS NOT NULL  GROUP BY Satis_Kanali order by Toplam_Musteri desc;