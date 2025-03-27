-- 1. Tanım Sorusu:  
-- Northwind veritabanında toplam kaç tablo vardır? Bu tabloların isimlerini listeleyiniz.

SELECT COUNT(*) AS TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';

-- 2. JOIN Sorusu:  
-- Her sipariş (Orders) için, Şirket adı (CompanyName), çalışan adı (Employee Full Name), sipariş tarihi ve 
-- gönderici şirketin adı (Shipper) ile birlikte bir liste çıkarın

SELECT * FROM nortwind.dbo.Orders
SELECT * FROM nortwind.dbo.Customers
SELECT * FROM nortwind.dbo.Employees
SELECT * FROM nortwind.dbo.Shippers

SELECT o.OrderID,c.CompanyName,e.FirstName,e.LastName, o.OrderDate, s.CompanyName
FROM nortwind.dbo.Orders o
JOIN nortwind.dbo.Employees e ON o.EmployeeID = e.EmployeeID
JOIN nortwind.dbo.Customers c ON CAST(o.CustomerID AS VARCHAR(5))  = c.CustomerID
JOIN nortwind.dbo.Shippers s ON o.ShipVia = s.ShipperID

-- 3. Aggregate Fonksiyon:  
-- Tüm siparişlerin toplam tutarını bulun. (Order Details tablosundaki Quantity  UnitPrice üzerinden hesaplayınız)
SELECT * FROM nortwind.dbo.[Order Details];
SELECT SUM(ordet.Quantity*ordet.UnitPrice) as 'Toplam: ' FROM nortwind.dbo.[Order Details] AS ordet;

-- 4. Gruplama:  
-- Hangi ülkeden kaç müşteri vardır?
SELECT * FROM nortwind.dbo.Customers

SELECT cus.Country, COUNT(cus.Country) AS 'Müşteri Sayısı'
FROM nortwind.dbo.Customers cus
GROUP BY cus.Country

-- 5. Subquery Kullanımı:  
-- En pahalı ürünün adını ve fiyatını listeleyiniz.

SELECT * FROM nortwind.dbo.Products

SELECT MAX(prd.UnitPrice) FROM nortwind.dbo.Products prd

SELECT prd.ProductName, prd.UnitPrice 
FROM nortwind.dbo.Products prd
WHERE prd.UnitPrice = (SELECT MAX(prd2.UnitPrice) FROM nortwind.dbo.Products prd2)

-- 6. JOIN ve Aggregate:  
-- Çalışan başına düşen sipariş sayısını gösteren bir liste çıkarınız.

SELECT * FROM nortwind.dbo.Orders
SELECT * FROM nortwind.dbo.Employees

SELECT emp.FirstName,emp.LastName, COUNT(ord.OrderID) 'Sipariş Sayısı'
FROM nortwind.dbo.Orders ord
JOIN nortwind.dbo.Employees emp ON ord.EmployeeID = emp.EmployeeID
GROUP BY emp.FirstName,emp.LastName
ORDER BY COUNT(ord.OrderID) DESC

SELECT O.OrderID FROM nortwind.dbo.Orders O
WHERE O.EmployeeID =1

-- 7. Tarih Filtreleme:  
-- 1997 yılında verilen siparişleri listeleyin.

SELECT * FROM nortwind.dbo.Orders

SELECT * FROM nortwind.dbo.Orders ord
WHERE DATEPART(YEAR,ord.OrderDate) = '1997'

-- 8. CASE Kullanımı:  
-- Ürünleri fiyat aralıklarına göre kategorilere ayırarak listeleyin: 020 → Ucuz, 2050 → Orta, 50+ → Pahalı.

SELECT * FROM nortwind.dbo.Products prd

SELECT 
    prd.ProductName,
    prd.UnitPrice,
    CASE
        WHEN prd.UnitPrice <= 20 THEN 'Ucuz'
        WHEN prd.UnitPrice > 20 AND prd.UnitPrice <= 50 THEN 'Orta'
        ELSE 'Pahalı'
    END AS 'Kategori'
FROM nortwind.dbo.Products prd
ORDER BY prd.UnitPrice;

-- 9.Nested Subquery:  
-- En çok sipariş verilen ürünün adını ve sipariş adedini (adet bazında) bulun.
SELECT * FROM nortwind.dbo.[Order Details]
SELECT * FROM nortwind.dbo.Products

SELECT  prd.ProductName,COUNT(*) 'Sipariş Adet'
FROM nortwind.dbo.Products prd
JOIN nortwind.dbo.[Order Details] ordet ON prd.ProductID = ordet.ProductID
GROUP BY prd.ProductName
ORDER BY COUNT(*) DESC

SELECT TOP(1) prd.ProductName,COUNT(*) 'Sipariş Adet'
FROM nortwind.dbo.Products prd
JOIN nortwind.dbo.[Order Details] ordet ON prd.ProductID = ordet.ProductID
GROUP BY prd.ProductName
ORDER BY COUNT(*) DESC

SELECT * FROM nortwind.dbo.[Order Details] ODET
WHERE ODET.ProductID =11

-- 10. View Oluşturma:  
-- Ürünler ve kategoriler bilgilerini birleştiren bir görünüm (view) oluşturun.
SELECT * FROM nortwind.dbo.Products
SELECT * FROM nortwind.dbo.Categories

SELECT prd.ProductID, prd.ProductName, cat.CategoryID ,cat.CategoryName, cat.Description
FROM nortwind.dbo.Products prd
JOIN nortwind.dbo.Categories cat ON prd.CategoryID=cat.CategoryID


-- 11. Trigger:  
-- Ürün silindiğinde log tablosuna kayıt yapan bir trigger yazınız.

-- 12. Stored Procedure:  
--Belirli bir ülkeye ait müşterileri listeleyen bir stored procedure yazınız.
SELECT * FROM nortwind.dbo.Customers
go

CREATE PROCEDURE musteri
		@CountryName NVARCHAR(50)
	AS
		SELECT cus.CustomerID, cus.CompanyName, cus.ContactName, cus.Country
		FROM nortwind.dbo.Customers cus
		WHERE Country = @CountryName;


EXEC musteri 'Mexico';


-- 13. Left Join Kullanımı:  
-- Tüm ürünlerin tedarikçileriyle (suppliers) birlikte listesini yapın. Tedarikçisi olmayan ürünler de listelensin.

SELECT * FROM nortwind.dbo.Products
SELECT * FROM nortwind.dbo.Suppliers

SELECT * 
FROM nortwind.dbo.Products prd
LEFT JOIN nortwind.dbo.Suppliers sup ON prd.SupplierID = sup.SupplierID

 SELECT * 
FROM nortwind.dbo.Products prd
JOIN nortwind.dbo.Suppliers sup ON prd.SupplierID = sup.SupplierID

-- 14. Fiyat Ortalamasının Üzerindeki Ürünler:  
-- Fiyatı ortalama fiyatın üzerinde olan ürünleri listeleyin.

SELECT * FROM nortwind.dbo.Products

SELECT AVG(prd.UnitPrice) 'Ortalama Fiyat' FROM nortwind.dbo.Products prd

SELECT prd.ProductName,prd.UnitPrice 
FROM nortwind.dbo.Products AS prd
WHERE prd.UnitPrice > (
	SELECT AVG(prd2.UnitPrice) 
	FROM nortwind.dbo.Products prd2
	)
ORDER BY prd.UnitPrice


-- 15. En Çok Ürün Satan Çalışan:  
-- Sipariş detaylarına göre en çok ürün satan çalışan kimdir?

SELECT * FROM nortwind.dbo.Employees
SELECT * FROM nortwind.dbo.Orders

SELECT emp.FirstName, emp.LastName, COUNT(ord.OrderID) 'Toplam Ürün Sayısı'
FROM nortwind.dbo.Orders ord
JOIN nortwind.dbo.Employees emp ON ord.EmployeeID = emp.EmployeeID
GROUP BY emp.FirstName,emp.LastName
ORDER BY COUNT(ord.OrderID) DESC

SELECT TOP (1) emp.FirstName, emp.LastName, COUNT(ord.OrderID) 'Toplam Ürün Sayısı'
FROM nortwind.dbo.Orders ord
JOIN nortwind.dbo.Employees emp ON ord.EmployeeID = emp.EmployeeID
GROUP BY emp.FirstName,emp.LastName
ORDER BY COUNT(ord.OrderID) DESC

-- 16. Ürün Stoğu Kontrolü:  
-- Stok miktarı 10’un altında olan ürünleri listeleyiniz.

SELECT * FROM nortwind.dbo.Products

SELECT prd.UnitsInStock,* FROM nortwind.dbo.Products AS prd
WHERE prd.UnitsInStock<10
ORDER BY prd.UnitsInStock DESC


-- 17. Şirketlere Göre Sipariş Sayısı:  
-- Her müşteri şirketinin yaptığı sipariş sayısını ve toplam harcamasını bulun.
SELECT * FROM nortwind.dbo.Orders
SELECT * FROM nortwind.dbo.[Order Details]
SELECT * FROM nortwind.dbo.Customers

SELECT cus.CompanyName, COUNT(DISTINCT ordet.OrderID) 'Toplam Sipariş', SUM(ordet.UnitPrice*ordet.Quantity) 'Toplam Tutar'
FROM nortwind.dbo.Orders ord
JOIN nortwind.dbo.[Order Details] ordet ON ord.OrderID = ordet.OrderID
JOIN nortwind.dbo.Customers cus ON ord.CustomerID = cus.CustomerID
GROUP BY cus.CompanyName
ORDER BY SUM(ordet.UnitPrice*ordet.Quantity) DESC

SELECT * FROM nortwind.dbo.[Order Details] oodet
where oodet.OrderID = 10259

SELECT * FROM nortwind.dbo.Orders oo
where oo.CustomerID = 'CENTC'

-- 18. En Fazla Müşterisi Olan Ülke:  
-- Hangi ülkede en fazla müşteri var?
SELECT * FROM nortwind.dbo.Customers

SELECT cus.Country, COUNT(cus.Country) 'Müşteri Sayısı' FROM nortwind.dbo.Customers cus
GROUP BY cus.Country
ORDER BY COUNT(cus.Country) DESC


-- 19. Her Siparişteki Ürün Sayısı:  
-- Siparişlerde kaç farklı ürün olduğu bilgisini listeleyin.
SELECT * FROM nortwind.dbo.[Order Details] ordet

SELECT COUNT(DISTINCT ordet.ProductID)'Farklı Ürün Sayısı' FROM nortwind.dbo.[Order Details] ordet
SELECT DISTINCT ordet.ProductID FROM nortwind.dbo.[Order Details] ordet

-- 20. Ürün Kategorilerine Göre Ortalama Fiyat:  
-- Her kategoriye göre ortalama ürün fiyatını bulun.

SELECT pro.CategoryID,AVG(pro.UnitPrice)'Ortalama Fiyat' FROM nortwind.dbo.Products pro
GROUP BY pro.CategoryID

-- 21. Aylık Sipariş Sayısı:  
-- Siparişleri ay ay gruplayarak kaç sipariş olduğunu listeleyin

SELECT * FROM nortwind.dbo.Orders

SELECT DATEPART(MONTH,ord.OrderDate)'Ay',COUNT(ord.OrderDate)'Sipariş Sayısı' 
FROM nortwind.dbo.Orders ord
GROUP BY DATEPART(MONTH,ord.OrderDate)
ORDER BY DATEPART(MONTH,ord.OrderDate)


-- 22. Çalışanların Müşteri Sayısı:  
-- Her çalışanın ilgilendiği müşteri sayısını listeleyin.

SELECT * FROM nortwind.dbo.Orders
SELECT * FROM nortwind.dbo.Employees

SELECT emp.FirstName,emp.LastName, COUNT(DISTINCT ord.CustomerID) 'Müşteri Sayısı'
FROM nortwind.dbo.Orders ord
JOIN nortwind.dbo.Employees emp ON ord.EmployeeID = emp.EmployeeID
GROUP BY emp.FirstName,emp.LastName
ORDER BY COUNT(DISTINCT ord.CustomerID) DESC

SELECT DISTINCT O.CustomerID FROM nortwind.dbo.Orders O
WHERE O.EmployeeID =5

-- 23. Hiç siparişi olmayan müşterileri listeleyin.

SELECT DISTINCT CustomerID FROM nortwind.dbo.Orders
SELECT * FROM nortwind.dbo.Customers

-- 24. Siparişlerin Nakliye (Freight) Maliyeti Analizi:  
-- Nakliye maliyetine göre en pahalı 5 siparişi listeleyin

SELECT TOP(5) iv.Freight FROM nortwind.dbo.Invoices iv
ORDER BY iv.Freight DESC

SELECT DISTINCT TOP(5) iv.Freight FROM nortwind.dbo.Invoices iv
ORDER BY iv.Freight DESC