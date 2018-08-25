USE WMS
GO

--2.	Insert
INSERT INTO Clients(FirstName, LastName, Phone) VALUES
('Teri', 'Ennaco', '570-889-5187'),
('Merlyn', 'Lawler', '201-588-7810'),
('Georgene', 'Montezuma', '925-615-5185'),
('Jettie', 'Mconnell', '908-802-3564'),
('Lemuel', 'Latzke', '631-748-6479'),
('Melodie', 'Knipp', '805-690-1682'),
('Candida', 'Corbley', '908-275-8357')

INSERT INTO Parts(SerialNumber, Description, Price, VendorId) VALUES
('WP8182119',	'Door Boot Seal',	117.86,	(SELECT VendorId FROM Vendors WHERE Name = 'Suzhou Precision Products')),
('W10780048',	'Suspension Rod',	42.81,	
(SELECT VendorId FROM Vendors WHERE Name = 'Shenzhen Ltd.')),
('W10841140',	'Silicone Adhesive',	6.77,	(SELECT VendorId FROM Vendors WHERE Name = 'Fenghua Import Export')),
('WPY055980',	'High Temperature Adhesive',	13.94,	(SELECT VendorId FROM Vendors WHERE Name = 'Qingdao Technology'))

--3.	Update
UPDATE Jobs
SET MechanicId = 3
WHERE Status = 'Pending'

UPDATE Jobs
SET Status = 'In Progress'
WHERE Status = 'Pending'

--4.	Delete
DELETE FROM OrderParts
WHERE OrderId = 19

DELETE FROM Orders
WHERE OrderId = 19