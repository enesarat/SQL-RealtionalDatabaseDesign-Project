-----------------SECTION 1------------
--------CREATE DATABASE-----------
USE master
CREATE DATABASE VoteIT3;
USE VoteIT3;
GO
CREATE SCHEMA VotingSystem;
GO

CREATE TABLE VotingSystem.Voter(
UserID INT IDENTITY PRIMARY KEY,
UserName NVARCHAR(20) NOT NULL,
UserSurname NVARCHAR(20) NOT NULL,
UserUsername NVARCHAR(20) NOT NULL,
UserEmail NVARCHAR(30) NOT NULL,
UserPassword NVARCHAR(20) NOT NULL,
UserCountry INT,
UserGender INT,
MaritalStatus INT,
JobStatus INT,
UserAge INT NOT NULL
)

CREATE TABLE  VotingSystem.SysAdmin(
AdminID INT IDENTITY PRIMARY KEY,
Username NVARCHAR(30) NOT NULL,
FirstName NVARCHAR(25),
LastName NVARCHAR(25),
AdminPassword NVARCHAR(25) NOT NULL, 
AdminPermissions NVARCHAR(1000)
)


CREATE TABLE VotingSystem.MaritalS(
MStatuID INT IDENTITY PRIMARY KEY,
MStatuName NVARCHAR(25) NOT NULL,
)

CREATE TABLE VotingSystem.JobS(
JStatuID INT IDENTITY PRIMARY KEY,
JStatuName NVARCHAR(25) NOT NULL,
)


CREATE TABLE VotingSystem.Voting(
VotingID INT IDENTITY PRIMARY KEY,
VotingName NVARCHAR(60) NOT NULL,
VotingCategory INT NOT NULL,
VotingDescription NVARCHAR(500) NOT NULL,
VotingDate DATE,
VotingEndDate DATE
)



CREATE TABLE VotingSystem.Vote(
VoteID INT IDENTITY PRIMARY KEY,
User_Key INT,
Voting_Key INT,
Option_Key INT,
VoteDate DATE	/**/
)

CREATE TABLE VotingSystem.VotingOption(
OptionID INT IDENTITY PRIMARY KEY,
OptionDescription NVARCHAR(500) NOT NULL,
Voting_Key INT,
Amount INT,
Statu INT
)

CREATE TABLE VotingSystem.Result(
ResultID INT IDENTITY PRIMARY KEY,
ResultDescription NVARCHAR(20)
)



CREATE TABLE VotingSystem.Country(
CountryID INT IDENTITY PRIMARY KEY,
CountryName NVARCHAR(25) NOT NULL,
)

CREATE TABLE VotingSystem.Gender(
GenderID INT IDENTITY PRIMARY KEY,
GenderName NVARCHAR(10) NOT NULL,
)

CREATE TABLE VotingSystem.Category(
CategoryID INT IDENTITY PRIMARY KEY,
CategoryName NVARCHAR(25) NOT NULL, /**/
)

ALTER TABLE VotingSystem.Vote
ADD CONSTRAINT fk_Vote_User
FOREIGN KEY (User_Key) REFERENCES VotingSystem.Voter(UserId);

ALTER TABLE VotingSystem.Vote
ADD CONSTRAINT fk_Vote_Voting
FOREIGN KEY (Voting_Key) REFERENCES VotingSystem.Voting(VotingID);


ALTER TABLE VotingSystem.Vote
ADD CONSTRAINT fk_Vote_VotOption
FOREIGN KEY (Option_Key) REFERENCES VotingSystem.VotingOption(OptionID);

ALTER TABLE VotingSystem.VotingOption
ADD CONSTRAINT fk_VotOption_Voting
FOREIGN KEY (Voting_Key) REFERENCES VotingSystem.Voting(VotingID);


ALTER TABLE VotingSystem.Voter
ADD CONSTRAINT fk_Voter_Country
FOREIGN KEY (UserCountry) REFERENCES VotingSystem.Country(CountryID);

ALTER TABLE VotingSystem.Voter
ADD CONSTRAINT fk_Voter_Gender
FOREIGN KEY (UserGender) REFERENCES VotingSystem.Gender(GenderID);

ALTER TABLE VotingSystem.Voting
ADD CONSTRAINT fk_Voting_Category
FOREIGN KEY (VotingCategory) REFERENCES VotingSystem.Category(CategoryID);

ALTER TABLE VotingSystem.Voter
ADD CONSTRAINT fk_Voter_JobS
FOREIGN KEY (JobStatus) REFERENCES VotingSystem.JobS(JStatuID);

ALTER TABLE VotingSystem.Voter
ADD CONSTRAINT fk_Voter_MaritalS
FOREIGN KEY (MaritalStatus) REFERENCES VotingSystem.MaritalS(MStatuID);


ALTER TABLE VotingSystem.VotingOption
ADD CONSTRAINT fk_Option_Result
FOREIGN KEY (Statu) REFERENCES VotingSystem.Result(ResultID);



---------------SECTION 2-------------
-----------TRÝGGERS-------------
USE [VoteIT3]
GO
--(1)----Kullanýcý 1 seçimde yalnýz 1 kez oy kullanabilir--

CREATE TRIGGER VotingSystem.AddVote
ON VotingSystem.Vote
INSTEAD OF INSERT
AS
	DECLARE @ID AS INT
	DECLARE @VotingKey AS INT
	DECLARE @OptionKEy AS INT
	DECLARE @VoteDate AS DATE
	SET @ID =(SELECT User_Key FROM inserted);
	SET @VotingKey =(SELECT Voting_Key FROM inserted);
	SET @OptionKEy =(SELECT Option_Key FROM inserted);
	SET @VoteDate =(SELECT VoteDate FROM inserted);
	IF(@ID NOT IN (SELECT User_Key FROM VotingSystem.Vote WHERE Voting_Key=@VotingKey))
	BEGIN
		INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
		VALUES(@ID,@VotingKey,@OptionKEy,@VoteDate);
	END
	ELSE
	BEGIN
		PRINT '"This user already used a vote for this voting!"';
	END
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
----(2)----Oy kullanýlýnca seçeneðin oy miktarýný artýrmalýyýz--

CREATE TRIGGER VotingSystem.IncrementAmount
ON VotingSystem.Vote
AFTER INSERT
AS
	DECLARE @ID AS INT
	DECLARE @VotingKey AS INT
	DECLARE @OptionKEy AS INT
	DECLARE @VoteDate AS DATE
	SET @ID =(SELECT User_Key FROM inserted);
	SET @VotingKey =(SELECT Voting_Key FROM inserted);
	SET @OptionKEy =(SELECT Option_Key FROM inserted);
	SET @VoteDate =(SELECT VoteDate FROM inserted);
	UPDATE VotingOption SET Amount=Amount+1 WHERE OptionID=@OptionKey
	PRINT '"The voting process was completed successfully."';
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-----(3)----Kayýt Sýrasýnda Þifre ve Kullanýcý Adýný Kontrol Etme ve kayýt bilsini göstermeliyiz--

CREATE TRIGGER VotingSystem.UserCreateControl
ON VotingSystem.Voter
INSTEAD OF INSERT
AS
	DECLARE @ID AS INT
	DECLARE @UserName AS NVARCHAR(20)
	DECLARE @UserSurname AS NVARCHAR(20)
	DECLARE @UserUsername AS NVARCHAR(20)
	DECLARE @UserEmail NVARCHAR(30)
	DECLARE @UserPassword AS NVARCHAR(20)
	DECLARE @UserCountry AS INT
	DECLARE @UserGender AS INT
	DECLARE @MaritalS AS INT
	DECLARE @JobS AS INT
	DECLARE @UserAge AS INT

	SET @ID =(SELECT UserID FROM inserted);
	SET @UserName =(SELECT UserName FROM inserted);
	SET @UserSurname =(SELECT UserSurname FROM inserted);
	SET @UserUsername =(SELECT UserUsername FROM inserted);
	SET @UserEmail =(SELECT UserEmail FROM inserted);
	SET @UserPassword =(SELECT UserPassword FROM inserted);
	SET @UserCountry =(SELECT UserCountry FROM inserted);
	SET @UserGender=(SELECT UserGender FROM inserted);
	SET @MaritalS=(SELECT MaritalStatus FROM inserted);
	SET @JobS=(SELECT JobStatus FROM inserted);
	SET @UserAge=(SELECT UserAge FROM inserted);

	
	IF(@UserUsername NOT IN (SELECT UserUsername FROM VotingSystem.Voter WHERE UserUsername=@UserUsername))
		BEGIN
			IF(@UserEmail NOT IN (SELECT UserEmail FROM VotingSystem.Voter WHERE UserEmail=@UserEmail))
				BEGIN
					INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
					VALUES (@UserName,@UserSurname,@UserUsername,@UserEmail,@UserPassword,@UserCountry,@UserGender,@MaritalS,@JobS,@UserAge)
					PRINT @UserUsername + ' has been added into voting system.';
				END
			ELSE
				BEGIN
					PRINT '"Username or User Email Already has been used for a user!"';
				END
		END
	ELSE
	BEGIN
		PRINT '"Username or User Email Already has been used for a user!"';
	END
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
------(4)----Sistemden Kullanýcý silinirse o kullanýcýnýn oylarýný da silmeli ve tüm kayýtlardan düþmeliyiz--

CREATE TRIGGER VotingSystem.DeleteUserAndVote
ON VotingSystem.Voter
INSTEAD OF DELETE
AS
    DECLARE @ID AS INT
    DECLARE @UserUsername AS NVARCHAR(20)
    DECLARE @Vote INT
    DECLARE @Option INT
    DECLARE @count INT
    DECLARE @n INT
    
	SET @n=1;
    SET @UserUsername =(SELECT UserUsername FROM deleted);
    SET @count=(Select COUNT(OptionID) From VotingSystem.VotingOption)
    
	SELECT @ID=UserID FROM VotingSystem.Voter WHERE UserUsername=@UserUsername

    IF(@ID IN (SELECT UserID FROM VotingSystem.Voter WHERE UserID=@ID))
        BEGIN
            IF(@ID IN (SELECT User_Key FROM VotingSystem.Vote WHERE User_Key=@ID))
                BEGIN
                    WHILE @count >= 0
					BEGIN
						IF(@n IN (SELECT Option_Key FROM VotingSystem.Vote WHERE User_Key= @ID))
						BEGIN
							UPDATE VotingOption SET Amount=Amount-1 WHERE OptionID=@n;
						END
						
						SET @count=@count-1;
						SET @n=@n+1;
					END

                    DELETE FROM [VotingSystem].[Vote]
                    WHERE User_Key=@ID
                    PRINT '"Votes of ' + @UserUsername + ' have been deleted first."';

                    DELETE FROM [VotingSystem].[Voter]
                    WHERE UserID=@ID
                    PRINT '"' + @UserUsername + ' have been deleted from system."';

                END
            ELSE
                BEGIN
                    DELETE FROM [VotingSystem].[Voter]
                    WHERE UserID=@ID
                    PRINT '"' + @UserUsername + ' have been deleted from system."';
                END
        END
    ELSE
        BEGIN
            PRINT '"There is no such user registration in the system!"';
        END
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
--------(5)----Kullanýc kaydýnda parolada 

CREATE TRIGGER VotingSystem.PasswordSecure
ON VotingSystem.Voter
AFTER INSERT
AS
BEGIN
    DECLARE @ID AS INT
	DECLARE @UserName AS NVARCHAR(20)
	DECLARE @UserSurname AS NVARCHAR(20)
	DECLARE @UserPassword AS NVARCHAR(20)

SELECT @UserName=[UserName],@UserSurname=[UserSurname],@UserPassword=UserPassword FROM inserted

	IF(@UserPassword like '%'+@UserName+'%' or @UserPassword like '%'+@UserSurname+'%')
		BEGIN
		   PRINT '"Please avoid using first and last name in your password for your security!"';
		END

END


-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
--(6)----Kazanan tablosunu belirlemek 

CREATE TRIGGER VotingSystem.IncrementResult
ON VotingSystem.VotingOption
AFTER UPDATE
AS
	DECLARE @ResultID AS INT
	DECLARE @OptionID AS INT
	DECLARE @VotingID AS INT
	DECLARE @Amount1 AS INT
	DECLARE @Amount2 AS INT
	DECLARE @option1 as int
	declare @option2 as int
	SET @VotingID =(SELECT Voting_Key FROM inserted);
	SET @OptionID =(SELECT OptionID FROM inserted);
	SET @Amount1 = @VotingID * 2;
	SET @Amount2 = @Amount1 - 1;
	SET @option1 = (SELECT Amount from VotingOption where OptionID=@Amount2)
	SET @option2 = (SELECT Amount from VotingOption where OptionID=@Amount1)
	IF(@option1 = @option2)
		BEGIN
			UPDATE VotingOption SET Statu=3 WHERE OptionID=@Amount1 
			UPDATE VotingOption SET Statu=3 WHERE OptionID=@Amount2
		END
	
	ELSE IF (@option1 > @option2)
		BEGIN	
			UPDATE VotingOption SET Statu=2 WHERE OptionID=@Amount1
			update VotingOption SET Statu=1 WHERE OptionID=@Amount2
		END
	ELSE IF(@option1 < @option2)	
		BEGIN
			UPDATE VotingOption SET Statu=2 WHERE OptionID=@Amount2
			UPDATE VotingOption SET Statu=1 WHERE OptionID=@Amount1
		END

---
------------------SECTION 3------------
--------------FUNCTÝONS-----------

--(1)--Kullanýcý Adýný alýp bulunan kullanýcýnýn email adresini çýktý veren fonksiyon-------------

CREATE FUNCTION VotingSystem.GetUserEmail
(
	@UserUsername NVARCHAR(20)
)
RETURNS NVARCHAR(20)
AS
BEGIN
	DECLARE @email NVARCHAR(20)
	SET @email=(SELECT ISNULL(UserEmail,'')  FROM VotingSystem.Voter WHERE UserUsername=@UserUsername)
	RETURN @email
END

--PRINT VotingSystem.GetUserEmail('enes_arat');
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
---(2)--Kategori Adýný alýp bulunan Kategorideki soru sayýsýný veren fonksiyon-------------
CREATE FUNCTION VotingSystem.CategoryQuestionQty
(
	@Category NVARCHAR(25)
)
RETURNS INT
AS
BEGIN
DECLARE @VoteQty INT
SELECT @VoteQty = COUNT(Vtg.VotingID) FROM VotingSystem.Category AS C 
INNER JOIN VotingSystem.Voting AS Vtg ON C.CategoryID=Vtg.VotingCategory
WHERE C.CategoryName=@Category

RETURN @VoteQty
END

--PRINT VotingSystem.CategoryQuestionQty('Software');
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
---(3)--Kullanýcý asýný alýp kullanýcýnýn oy kullandýðý sorular ve kategorilerini veren fonksiyon ---
CREATE FUNCTION VotingSystem.VoterVoteAndAnswer
(
	@UserUsername NVARCHAR(20)

)
RETURNS TABLE
AS

RETURN
(
	SELECT Vt.VoteID AS 'Vote ID', Vtr.UserUsername AS 'Username',Vtg.VotingDescription AS 'The votes the user participated in',Vtg.VotingID AS 'Voting ID',C.CategoryName AS 'Category' FROM VotingSystem.Voter AS Vtr 
	INNER JOIN VotingSystem.Vote AS Vt ON Vtr.UserID=Vt.User_Key
	INNER JOIN VotingSystem.Voting AS Vtg ON Vt.Voting_Key=Vtg.VotingID
	INNER JOIN VotingSystem.Category AS C ON Vtg.VotingCategory=C.CategoryID
	WHERE Vtr.UserUsername=@UserUsername

)

--SELECT * FROM VotingSystem.VoterVoteAndAnswer('nbc');

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------


--------------------------------------SECTION 4-----------------------------------------------------------
---------------------------------------VÝEWS----------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------
---(1)--Sistemdeki tüm kullanýcýlarýn bilgilerini tutan view-------------

CREATE VIEW VotingSystem.GetVoterDetails
AS
SELECT Voter.UserName,Voter.UserSurname,Voter.UserUsername,Voter.UserEmail,Voter.UserPassword,Country.CountryName,Gender.GenderName,MaritalS.MStatuName,JobS.JStatuName,Voter.UserAge 
FROM VotingSystem.Voter,VotingSystem.Country,VotingSystem.Gender,VotingSystem.MaritalS,VotingSystem.JobS
WHERE Voter.UserCountry=Country.CountryID AND Voter.UserGender=Gender.GenderID AND Voter.MaritalStatus=MaritalS.MStatuID AND Voter.JobStatus=JobS.JStatuID
GO

SELECT * FROM VotingSystem.GetVoterDetails

-----------------------------------------------------------------------------------------------------------------------------------------------------
---(2)--Sistemdeki tüm adminlerin bilgilerini tutan view-------------

CREATE VIEW VotingSystem.GetAdminDetails
AS
SELECT SysAdmin.Username,SysAdmin.FirstName,SysAdmin.LastName,SysAdmin.AdminPassword,SysAdmin.AdminPermissions
FROM VotingSystem.SysAdmin
GO

SELECT * FROM VotingSystem.GetAdminDetails

-----------------------------------------------------------------------------------------------------------------------------------------------------
---(3)--Tüm kategorileri ve içerdiði oylamalarý tutan view-------------

CREATE VIEW VotingSystem.GetCatWQuestions
AS
SELECT Category.CategoryID,Category.CategoryName AS 'Voting Category',Voting.VotingID,Voting.VotingName AS 'Voting Name',Voting.VotingDescription AS 'Voting Description',Voting.VotingDate AS 'Voting Start Date',Voting.VotingEndDate AS 'Voting End Date'
FROM VotingSystem.Category 
LEFT JOIN VotingSystem.Voting
ON Category.CategoryID=Voting.VotingCategory
ORDER BY Category.CategoryID OFFSET 0 ROWS;
GO

SELECT * FROM VotingSystem.GetCatWQuestions

-----------------------------------------------------------------------------------------------------------------------------------------------------
---(4)--Tüm sorularý ve cevaplarýný tutan view-------------

CREATE VIEW VotingSystem.GetQesWAnswers
AS
SELECT Voting.VotingID,Voting.VotingName AS 'Voting Name',Voting.VotingDescription AS 'Voting Description',VotingOption.OptionID,VotingOption.OptionDescription AS 'Option Description'
FROM VotingSystem.Voting 
LEFT JOIN VotingSystem.VotingOption
ON Voting.VotingID=VotingOption.Voting_Key

SELECT * FROM VotingSystem.GetQesWAnswers

-----------------------------------------------------------------------------------------------------------------------------------------------------
---(5)--Tüm kullanýcýlar ve kullandýðý oylar -------------

CREATE VIEW VotingSystem.GetUserVotes
AS
SELECT u.UserUsername AS 'Username',o.OptionID,o.OptionDescription AS 'Option Description'
FROM VotingSystem.VotingOption o
INNER JOIN VotingSystem.Vote v ON o.OptionID=v.Option_Key
INNER JOIN VotingSystem.Voter u ON v.User_Key=u.UserID


SELECT * FROM VotingSystem.GetUserVotes

-----------------------------------------------------------------------------------------------------------------------------------------------------
---(6)--Ülkelere göre kullanýcýlarýn katýldýðý oylamalar -------------

CREATE VIEW VotingSystem.CountyWVotings
AS
SELECT c.CountryID,c.CountryName AS 'Voter Country', vtr.UserUsername AS 'Voter',vtg.VotingID, vtg.VotingDescription AS 'Voting',cg.CategoryID,cg.CategoryName
FROM VotingSystem.Country c
INNER JOIN VotingSystem.Voter vtr ON c.CountryID=vtr.UserCountry
INNER JOIN VotingSystem.Vote vt ON vtr.UserID=vt.User_Key
INNER JOIN VotingSystem.Voting vtg ON vt.Voting_Key=vtg.VotingID
INNER JOIN VotingSystem.Category cg ON vtg.VotingCategory=cg.CategoryID
ORDER BY c.CountryID OFFSET 0 ROWS;

SELECT * FROM VotingSystem.CountyWVotings

-----------------------------------------------------------------------------------------------------------------------------------------------------
---(7)--Cinsiyetlere göre kullanýcýlarýn katýldýðý oylamalar -------------

CREATE VIEW VotingSystem.GenderWVotings
AS
SELECT g.GenderID,g.GenderName AS 'Voter Gender', vtr.UserUsername AS 'Voter',vtg.VotingID, vtg.VotingDescription AS 'Voting',cg.CategoryID,cg.CategoryName
FROM VotingSystem.Gender g
INNER JOIN VotingSystem.Voter vtr ON g.GenderID=vtr.UserGender
INNER JOIN VotingSystem.Vote vt ON vtr.UserID=vt.User_Key
INNER JOIN VotingSystem.Voting vtg ON vt.Voting_Key=vtg.VotingID
INNER JOIN VotingSystem.Category cg ON vtg.VotingCategory=cg.CategoryID
ORDER BY g.GenderID OFFSET 0 ROWS;

SELECT * FROM VotingSystem.GenderWVotings

-----------------------------------------------------------------------------------------------------------------------------------------------------
---(8)--Ýþ durumuna göre kullanýcýlarýn katýldýðý oylamalar -------------

CREATE VIEW VotingSystem.JobWVotings
AS
SELECT j.JStatuID,j.JStatuName 'Voter Job Statu', vtr.UserUsername AS 'Voter',vtg.VotingID, vtg.VotingDescription AS 'Voting',cg.CategoryID,cg.CategoryName
FROM VotingSystem.JobS j
INNER JOIN VotingSystem.Voter vtr ON j.JStatuID=vtr.JobStatus
INNER JOIN VotingSystem.Vote vt ON vtr.UserID=vt.User_Key
INNER JOIN VotingSystem.Voting vtg ON vt.Voting_Key=vtg.VotingID
INNER JOIN VotingSystem.Category cg ON vtg.VotingCategory=cg.CategoryID
ORDER BY j.JStatuID OFFSET 0 ROWS;

SELECT * FROM VotingSystem.JobWVotings

-----------------------------------------------------------------------------------------------------------------------------------------------------
---(9)--Medeni hale göre kullanýcýlarýn katýldýðý oylamalar -------------

CREATE VIEW VotingSystem.MaritalWVotings
AS
SELECT m.MStatuID,m.MStatuName AS 'Voter Job Statu', vtr.UserUsername AS 'Voter',vtg.VotingID, vtg.VotingDescription AS 'Voting',cg.CategoryID,cg.CategoryName
FROM VotingSystem.MaritalS m
INNER JOIN VotingSystem.Voter vtr ON m.MStatuID=vtr.JobStatus
INNER JOIN VotingSystem.Vote vt ON vtr.UserID=vt.User_Key
INNER JOIN VotingSystem.Voting vtg ON vt.Voting_Key=vtg.VotingID
INNER JOIN VotingSystem.Category cg ON vtg.VotingCategory=cg.CategoryID
ORDER BY m.MStatuID OFFSET 0 ROWS;

SELECT * FROM VotingSystem.MaritalWVotings

--------------------EN ÇOK SEÇÝLEN OYLARIN SORULARINI VE KATEGORÝSÝNÝ GETÝREN VÝEW ---------------------------------------------------------------------------------------------------------------------------------
---(10)-- -------------
CREATE VIEW VotingSystem.GetWonAnswers
AS
SELECT Voting.VotingID ,VotingOption.OptionDescription as 'Answer', Voting.VotingDescription as 'Question',Category.CategoryID ,Category.CategoryName as 'Category' 
FROM VotingSystem.VotingOption, VotingSystem.Voting, VotingSystem.Category 
where Statu = 1 and Voting.VotingID = VotingOption.Voting_Key and Voting.VotingCategory = Category.CategoryID;

select * from VotingSystem.GetWonAnswers
------------ 10.1 EÞÝT SEÇÝLER OYLARIN SORULARINI VE KATEGORÝSÝNÝ GETÝREN VÝEW---------------------------

----------------------------

Create VIEW VotingSystem.GetDrawAnswers
AS
SELECT  Voting.VotingID ,VotingOption.OptionDescription as 'Answer', Voting.VotingDescription as 'Question',Category.CategoryID ,Category.CategoryName as 'Category' 
FROM VotingSystem.VotingOption, VotingSystem.Voting, VotingSystem.Category 
where Statu = 3 and Voting.VotingID = VotingOption.Voting_Key and Voting.VotingCategory = Category.CategoryID;

select * from VotingSystem.GetDrawAnswers


--------------SECTION 5-----------
---------------Procedures--------

USE [VoteIT3]
GO
------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------

--1  =>>Kullanýcýnýn totalde kaç oy kullandýðýný gösteren pros.					*	*	*	*	*	*	*	*

CREATE PROCEDURE VotingSystem.UserTotalVote(@UserName NVARCHAR(20))
AS
BEGIN
DECLARE @UserId INT
SELECT @UserId= UserID FROM VotingSystem.Voter 
WHERE UserUsername =@UserName
SELECT COUNT(Vote.Option_Key) AS 'Total Vote Amount' FROM VotingSystem.Vote
INNER JOIN VotingSystem.Voter
ON Vote.User_Key=Voter.UserID
WHERE Voter.UserUsername=@UserName
END
--EXEC VotingSystem.UserTotalVote @UserName= N'enes_arat';
--DROP PROCEDURE VotingSystem.UserTotalVote;

------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------

--2  =>>Kullanýcýnýn xxx tarihinde kullandýðý oylarý gösteren pros.					*	*	*	*	*	*	*	*

CREATE PROCEDURE VotingSystem.UserDateVote(@UserName NVARCHAR(20),@Date DATE)
AS
BEGIN
DECLARE @UserId INT, @VoteId INT
SELECT @UserId= UserID FROM VotingSystem.Voter 
WHERE UserUsername =@UserName

SELECT @VoteId= Vote.VoteID FROM VotingSystem.Vote
INNER JOIN VotingSystem.Voter
ON Vote.User_Key=Voter.UserID

SELECT OptionDescription AS 'Vote of User' FROM VotingSystem.VotingOption 
INNER JOIN VotingSystem.Vote ON VotingOption.OptionID=Vote.Option_Key
WHERE @Date=Vote.VoteDate AND Vote.User_Key=@UserID
END
--EXEC VotingSystem.UserDateVote @UserName=N'jd_online', @Date='2020-10-06';
--DROP PROCEDURE VotingSystem.UserDateVote

------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------

--3	 =>>En çok oylanan kategori								*	*	*	*	*	*	*	*		=>>Girilen kategoriye göre o kategoridekien cok oylanan

CREATE PROC VotingSystem.MostVotedCategory
AS 
BEGIN
DECLARE @id INT
SET 
	@id=(SELECT Top 1 CategoryID FROM VotingSystem.VotingOption
		INNER JOIN VotingSystem.Voting ON VotingID=Voting_Key
		INNER JOIN VotingSystem.Category ON CategoryID = VotingCategory 
		GROUP BY CategoryID
		ORDER BY SUM(Amount) DESC)

SELECT TOP 1 SUM(Amount) as 'Total Amount',CategoryID as 'Catgory ID',
		(select CategoryName from VotingSystem.Category where @id=CategoryID) as 'Category Name'FROM VotingSystem.VotingOption 
		INNER JOIN VotingSystem.Voting ON VotingID=Voting_Key
		INNER JOIN VotingSystem.Category ON CategoryID = VotingCategory 
		GROUP BY CategoryID ORDER BY SUM(Amount) DESC
END

--EXEC VotingSystem.MostVotedCategory

------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------

--4  =>>Girilen kategoriye göre o kategoriye toplam katýlým.					*	*	*	*	*	*	*	*

CREATE PROC VotingSystem.TotalAmountOfGivenCategory(@CatName NVARCHAR(20))
AS
BEGIN
DECLARE @Categoryid INT 
SELECT @Categoryid = CategoryID From VotingSystem.Category Where CategoryName=@CatName
SELECT CategoryID as 'Catgory ID',@CatName as 'Category Name',SUM(Amount) as 'Total Amount' FROM VotingSystem.VotingOption
INNER JOIN VotingSystem.Voting ON VotingOption.Voting_Key=Voting.VotingID
INNER JOIN VotingSystem.Category ON Voting.VotingCategory=Category.CategoryID 
WHERE @Categoryid = CategoryID 
GROUP BY CategoryID
END

--EXEC VotingSystem.TotalAmountOfGivenCategory N'Academic'

------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------

--5	 =>>En çok oylanan seçeneðin bulunduðu soru,kategorisi ve oy miktarlarý miktarlarý				*	*	*	*	*	*	*	*						=>>En çok Oylanan soruyu "ve bulunduðu keategoriyi" getiren pros.

CREATE PROCEDURE VotingSystem.MostVotedQuestionCat
AS
BEGIN
DECLARE @Option INT,@Amount INT,@VotingId INT,@OptionDesc NVARCHAR(20)
SELECT  @VotingId =MAX(Vote.Voting_Key) FROM VotingSystem.Vote
INNER JOIN VotingSystem.VotingOption ON Vote.Option_Key=VotingOption.OptionID
INNER JOIN VotingSystem.Voting ON VotingOption.Voting_Key=Voting.VotingID 

SELECT @Option=VotingOption.Amount,@OptionDesc=VotingOption.OptionDescription FROM VotingSystem.VotingOption WHERE VotingOption.Voting_Key=@VotingId

SELECT @Amount=COUNT(Vote.Voting_Key)FROM VotingSystem.Vote 
INNER JOIN VotingSystem.VotingOption
ON Vote.Option_Key=VotingOption.OptionID AND VotingOption.Voting_Key=@VotingId

SELECT Voting.VotingID,Voting.VotingDescription AS 'Most Voted Question',@OptionDesc AS 'Most Voted Option',@Option AS 'Vote Amount',Category.CategoryName AS 'Category',@Amount AS 'Tolal Vote Amount' FROM VotingSystem.Voting 
INNER JOIN VotingSystem.Category ON Voting.VotingCategory=Category.CategoryID AND Voting.VotingID=@VotingId
END
--DROP PROCEDURE VotingSystem.MostVotedQuestionCat

--EXEC VotingSystem.MostVotedQuestionCat

------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------

--6  =>>Cinsiyete göre ortak olan kullanýcýlarýn oylarý					*	*	*	*	*	*	*	*						 

CREATE PROCEDURE VotingSystem.JointGenderVotes(@Gender NVARCHAR(10)/*,@Marital NVARCHAR(25)*/)
AS
BEGIN
DECLARE @GenderId INT
SELECT @GenderId= GenderId FROM VotingSystem.Gender 
WHERE GenderName =@Gender

SELECT UserUsername,OptionDescription FROM VotingSystem.Voter
INNER JOIN VotingSystem.Vote ON Voter.UserID=Vote.User_Key
INNER JOIN VotingSystem.VotingOption ON Vote.Option_Key=VotingOption.OptionID
WHERE UserGender=@GenderId
END
--DROP PROCEDURE VotingSystem.JointGenderVotes

--EXEC VotingSystem.JointGenderVotes @Gender=N'Male'

------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------

--7-  =>> ---Medeni hale göre ortak olan kullanýcý oylarý		*	*	*	*	*	*	*	*

CREATE PROCEDURE VotingSystem.JointMaritalVotes(@Marital NVARCHAR(25)/*,@Marital NVARCHAR(25)*/)
AS
BEGIN
DECLARE @MaritalId INT
SELECT @MaritalId= MaritalS.MStatuID FROM VotingSystem.MaritalS 
WHERE MaritalS.MStatuName =@Marital

SELECT UserUsername,OptionDescription FROM VotingSystem.Voter
INNER JOIN VotingSystem.Vote ON Voter.UserID=Vote.User_Key
INNER JOIN VotingSystem.VotingOption ON Vote.Option_Key=VotingOption.OptionID
WHERE MaritalStatus=@MaritalId
END
--DROP PROCEDURE VotingSystem.JointMaritalVotes

--EXEC VotingSystem.JointMaritalVotes @Marital=N'Married'

------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------

--8  =>>xx ülkesinden oy kullanan kullanýcýlarý getiren pros.		*	*	*	*	*	*	*	*

CREATE PROCEDURE VotingSystem.CountryUserVote(@Country NVARCHAR(25))
AS
BEGIN
DECLARE @CountryId INT
SELECT @CountryID=CountryId FROM VotingSystem.Country
WHERE Country.CountryName=@Country 

SELECT UserUsername,@Country FROM VotingSystem.Voter
INNER JOIN VotingSystem.Vote ON Voter.UserID=Vote.User_Key
WHERE Voter.UserCountry=@CountryId
END
--DROP PROCEDURE VotingSystem.CountryUserVote

--EXEC VotingSystem.CountryUserVote @Country=N'USA'

------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------

--9  =>>25 yaþ üstü ve 65 yaþ altý kullanýcýlarýn ortak oylarý		*	*	*	*	*	*	*	*

CREATE PROCEDURE VotingSystem.MiddleAgeJointVote
AS
BEGIN
SELECT UserUsername,UserAge,OptionDescription FROM VotingSystem.Voter
INNER JOIN VotingSystem.Vote ON Voter.UserID=Vote.User_Key
INNER JOIN VotingSystem.VotingOption ON Vote.Option_Key=VotingOption.OptionID
WHERE UserAge<=65 AND UserAge>=25
END
--DROP PROCEDURE VotingSystem.MiddleAgeJointVote

--EXEC VotingSystem.MiddleAgeJointVote 

------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------
--10-xx kategorisinde oylamam yapan kullanýcýlarýn yaþ ortalamasýný getiren pros.		*	*	*	*	*	*	*	*

CREATE PROCEDURE VotingSystem.CatAvgAge(@Category NVARCHAR(25))
AS
BEGIN
DECLARE @CategoryId INT
SELECT @CategoryId=CategoryId FROM VotingSystem.Category
WHERE Category.CategoryName=@Category
SELECT AVG(Vtr.UserAge) FROM VotingSystem.Voter AS Vtr
INNER JOIN VotingSystem.Vote AS Vt ON Vtr.UserID=Vt.User_Key
INNER JOIN VotingSystem.Voting AS Vtg ON Vt.Voting_Key=Vtg.VotingID
WHERE Vtg.VotingCategory=@CategoryId
END

--EXEC VotingSystem.CatAvgAge @Category=N'Graphics and Design'

------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------11------Süresi geçen sorularýn kaç gün önce bittiðini veya kaç gün sonra baþlayacaðýný getiren pros------------------------

create proc VotingSystem.DeadQuestions (@VotingID INT)
AS BEGIN
declare @sdate DATE
DECLARE @edate Date
declare @now date
set @VotingID = (select Voting.VotingID FROM VotingSystem.Voting where @VotingID= VotingID)
set @sdate=(select v.VotingDate from VotingSystem.Voting v where @VotingID = VotingID)
set @edate=(select v.VotingEndDate from VotingSystem.Voting v where @VotingID = VotingID)
set @now = (SELECT GETDATE());
IF(@now < @sdate ) begin
SELECT DATEDIFF(DAY,GETDATE(),@sdate) as 'Starts will', DATEDIFF(DAY,GETDATE(),@edate) as 'Ends will', VotingName from VotingSystem.Voting where @VotingID=VotingID end
else IF(@now < @edate)begin
SELECT DATEDIFF(DAY,@sdate,GETDATE()) as 'Start Days Ago', DATEDIFF(DAY,GETDATE(),@edate) as 'End in', VotingName from VotingSystem.Voting where @VotingID=VotingID end 
else begin
SELECT DATEDIFF(DAY,@sdate,GETDATE()) as 'Start Days Ago', DATEDIFF(DAY,@edate,GETDATE()) as 'Ends days ago', VotingName from VotingSystem.Voting where @VotingID=VotingID end
end
--exec VotingSystem.DeadQuestions 11
-------------SECTION 6------
-----------ADD TABLE-----
USE [VoteIT3]
GO
--CATEGORIES
INSERT INTO [VotingSystem].[Category] ([CategoryName]) VALUES ('Academic')
GO
INSERT INTO [VotingSystem].[Category] ([CategoryName]) VALUES('Math')
GO
INSERT INTO [VotingSystem].[Category] ([CategoryName]) VALUES ('Chemistry')
GO
INSERT INTO [VotingSystem].[Category] ([CategoryName]) VALUES ('Biology')
GO
INSERT INTO [VotingSystem].[Category] ([CategoryName]) VALUES ('Software')
GO
INSERT INTO [VotingSystem].[Category] ([CategoryName]) VALUES ('Theater')
GO
INSERT INTO [VotingSystem].[Category] ([CategoryName]) VALUES ('Music')
GO
INSERT INTO [VotingSystem].[Category] ([CategoryName]) VALUES ('History')
GO
INSERT INTO [VotingSystem].[Category] ([CategoryName]) VALUES ('Graphics and Design')
GO
INSERT INTO [VotingSystem].[Category] ([CategoryName]) VALUES ('Physic')
GO

--COUNTRIES
INSERT INTO [VotingSystem].[Country] ([CountryName]) VALUES ('Turkey')
GO
INSERT INTO [VotingSystem].[Country] ([CountryName]) VALUES ('Germany')
GO
INSERT INTO [VotingSystem].[Country] ([CountryName]) VALUES ('France')
GO
INSERT INTO [VotingSystem].[Country] ([CountryName]) VALUES ('Russia')
GO
INSERT INTO [VotingSystem].[Country] ([CountryName]) VALUES ('USA')
GO
INSERT INTO [VotingSystem].[Country] ([CountryName]) VALUES ('England')
GO
INSERT INTO [VotingSystem].[Country] ([CountryName]) VALUES ('China')
GO
INSERT INTO [VotingSystem].[Country] ([CountryName]) VALUES ('Ukraine')
GO
INSERT INTO [VotingSystem].[Country] ([CountryName]) VALUES ('Italy')
GO
INSERT INTO [VotingSystem].[Country] ([CountryName]) VALUES ('Spain')
GO

--GENDER
INSERT INTO [VotingSystem].[Gender] ([GenderName]) VALUES ('Male')
GO
INSERT INTO [VotingSystem].[Gender] ([GenderName]) VALUES ('Female')
GO
INSERT INTO [VotingSystem].[Gender] ([GenderName]) VALUES ('Custom')
GO

--JOB STATU
INSERT INTO [VotingSystem].[JobS] ([JStatuName]) VALUES ('Employed')
GO
INSERT INTO [VotingSystem].[JobS] ([JStatuName]) VALUES ('Unemployed')
GO
INSERT INTO [VotingSystem].[JobS] ([JStatuName]) VALUES ('Student')
GO

--MARITAL STATU
INSERT INTO [VotingSystem].[MaritalS] ([MStatuName]) VALUES ('Single')
GO
INSERT INTO [VotingSystem].[MaritalS] ([MStatuName]) VALUES ('Married')
GO

--RESULT
INSERT INTO [VotingSystem].[Result]([ResultDescription]) VALUES('won')
GO
INSERT INTO [VotingSystem].[Result]([ResultDescription]) VALUES('lost')
GO
INSERT INTO [VotingSystem].[Result]([ResultDescription]) VALUES('draw')
GO

--VOTINGS/QUESTIONS
INSERT INTO [VotingSystem].[Voting] ([VotingName],[VotingCategory],[VotingDescription],[VotingDate],[VotingEndDate])
VALUES ('Distance in Education' ,1 ,'In education, do you prefer face-to-face or distance education?' ,'10.12.2020' ,'10.01.2021')--face-to-face/distance
GO
INSERT INTO [VotingSystem].[Voting] ([VotingName],[VotingCategory],[VotingDescription],[VotingDate],[VotingEndDate])--yes/no
VALUES ('Lessons in Distance Education' ,1 ,'With distance education, do you find it beneficial for students to be given many homework from all courses?' ,'10.12.2020' ,'10.01.2021')--face-to-face/distance
GO
INSERT INTO [VotingSystem].[Voting] ([VotingName],[VotingCategory],[VotingDescription],[VotingDate],[VotingEndDate])--problem solving/memorization
VALUES ('Math Education Style' ,2 ,'In the region you live in, do you think mathematics education is oriented towards memorization or problem solving?' ,'10.05.2020' ,'10.08.2020')
GO
INSERT INTO [VotingSystem].[Voting] ([VotingName],[VotingCategory],[VotingDescription],[VotingDate],[VotingEndDate])--theoretical/laboratory
VALUES ('Learning Chemistry' ,3 ,'Do you think theoretical education is more effective in chemistry education or is laboratory education?' ,'10.06.2020' ,'10.08.2020')
GO
INSERT INTO [VotingSystem].[Voting] ([VotingName],[VotingCategory],[VotingDescription],[VotingDate],[VotingEndDate])--yes/no
VALUES ('Biology Education' ,4 ,'Do you think that there is an education method that aims to be successful only in the university entrance exam in biology education in your region?' ,'10.12.2020' ,'10.2.2021')
GO
INSERT INTO [VotingSystem].[Voting] ([VotingName],[VotingCategory],[VotingDescription],[VotingDate],[VotingEndDate])--lecturing/problem solving
VALUES ('Software Development' ,5 ,'Do you prefer more lecturing or giving problems to the student in software training?' ,'10.05.2020' ,'10.01.2021')
GO
INSERT INTO [VotingSystem].[Voting] ([VotingName],[VotingCategory],[VotingDescription],[VotingDate],[VotingEndDate])--by individual/with group
VALUES ('Working in Software' ,5 ,'In software education, which one do you think is more effective in the learning process between students individual work and working in groups?' ,'10.09.2020' ,'10.01.2021')
GO
INSERT INTO [VotingSystem].[Voting] ([VotingName],[VotingCategory],[VotingDescription],[VotingDate],[VotingEndDate])--yes/no
VALUES ('Online Software Courses' ,5 ,'In software education, can online software courses enable students to develop and learn new technologies?' ,'10.11.2020' ,'10.01.2021')
GO
INSERT INTO [VotingSystem].[Voting] ([VotingName],[VotingCategory],[VotingDescription],[VotingDate],[VotingEndDate])--correct/uncorrect
VALUES ('Conservatory Theater Education' ,6 ,'Although there are many methods in acting, do you find it correct to concentrate on one method in most of the conservatory acting sections?' ,'10.09.2020' ,'10.11.2020')
GO
INSERT INTO [VotingSystem].[Voting] ([VotingName],[VotingCategory],[VotingDescription],[VotingDate],[VotingEndDate])--yes/no
VALUES ('Conservatory Music Education' ,7 ,'In the introduction to music education; Is it true that a student candidate whose voice color and tone is not good even though he / she completes the basic competencies can be a vocal artist?' ,'10.12.2020' ,'10.2.2021')
GO
INSERT INTO [VotingSystem].[Voting] ([VotingName],[VotingCategory],[VotingDescription],[VotingDate],[VotingEndDate])--enough/not enough
VALUES ('History Studies in Education' ,8 ,'In the history departments of universities, do you find the researches sufficient or do you think more historical research should be done in the education process?' ,'10.5.2020' ,'10.8.2020')
GO
INSERT INTO [VotingSystem].[Voting] ([VotingName],[VotingCategory],[VotingDescription],[VotingDate],[VotingEndDate])--yes/no
VALUES ('Design Trends' ,9 ,'In design education, do you see design trends changing every year as a necessary innovation?' ,'10.10.2020' ,'10.01.2021')
GO
INSERT INTO [VotingSystem].[Voting] ([VotingName],[VotingCategory],[VotingDescription],[VotingDate],[VotingEndDate])--yes/no
VALUES ('Physics in Education' ,10 ,'Do you think that sufficient knowledge is provided in physics education in educational institutions in physics fields other than the one that is common in daily life?' ,'10.11.2020' ,'05.01.2021')
GO
INSERT INTO [VotingSystem].[Voting] ([VotingName],[VotingCategory],[VotingDescription],[VotingDate],[VotingEndDate])--yes/no
VALUES ('Physics in Real Life' ,10 ,'Do you think
There is a difference between the physics course taught in school and the laws of physics in real life?' ,'10.11.2020' ,'05.01.2021')
GO
-----------------------------------------------------------------------------------------------------------------------------

--VOTING OPTION
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('face-to-face' ,'1' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('distance' ,'1' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('yes' ,'2' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('no' ,'2' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount])
VALUES ('problem solving' ,'3' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('memorization' ,'3' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('theoretical' ,'4' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('laboratory' ,'4' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('yes' ,'5' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('no' ,'5' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('lecturing' ,'6' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('problem solving' ,'6' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('by individual' ,'7' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('with group' ,'7' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount])
VALUES ('yes' ,'8' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('no' ,'8' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('correct' ,'9' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('uncorect' ,'9' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('yes' ,'10' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('no' ,'10' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('enough' ,'11' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('not enough' ,'11' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('yes' ,'12' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('no' ,'12' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('yes' ,'13' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('no' ,'13' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('yes' ,'14' ,0)
GO
INSERT INTO [VotingSystem].[VotingOption] ([OptionDescription] ,[Voting_Key] ,[Amount] )
VALUES ('no' ,'14' ,0)
GO
-------------------------------------------------------------------------------------------

--ADMIN
INSERT INTO [VotingSystem].[SysAdmin]([Username],[FirstName],[LastName],[AdminPassword],[AdminPermissions])
     VALUES('admin','System','Administration','admin','Admin can edit events in the system and add voting, add and rearrange options in voting, intervene users if necessary.')
GO


--VOTER
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Enes','Arat','enes_arat','enes@gmail.com','enes123',1,1,1,3,21)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Fatih','Tanyýlmaz','fthtnylmz','fatih@gmail.com','fatih123',1,1,1,3,22)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Eren','Arat','erenarat','eren@gmail.com','eren123321',1,1,1,3,20)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Johnny','Depp','jd_online','jdepp@gmail.com','johnny12345',5,1,1,1,57)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Jack','Nicholson','nicholson_j','nicholson@gmail.com','jack123',5,1,2,1,83)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Fatih','Terim','fatih_terim_1905','f_terim@gmail.com','fatih1905',1,1,2,1,67)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Lukas','Podolski','podolski10','podolski@gmail.com','lukas123',2,1,2,1,35)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Nastassja','Kinski','NastasjaK','kinsski@gmail.com','kinski123321',4,2,1,1,59)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Jackie','Chan','jackie_chan','jc@gmail.com','jackie123',7,1,2,1,66)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Stanley','Kubrick','kubrick01','s_kubrick@gmail.com','shining123',5,1,2,1,41)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Nuri Bilge','Ceylan','nbc','nbc@gmail.com','123nbc',1,1,2,1,61)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Haluk','Bilginer','HalukBilginer','h_bilginer@gmail.com','haluk123',1,1,1,1,66)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Öykü','Karayel','öyküKarayel34','öykü_k@gmail.com','öykü123',1,2,2,1,30)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Türkan','Þoray','türkanOnline','türkanþoray@gmail.com','türkan1234',1,2,2,1,75)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Nicole','Kidman','n_kidman','kidman@gmail.com','nicole123',2,2,2,1,53)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Margot','Robbie','margot_robbie','m_robbie@gmail.com','margot123',5,2,2,1,30)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Leonardo','Di Caprio','di_caprio','leodicaprio@gmail.com','ihaveoneoscar',5,1,1,1,46)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Alina','Boz','a_boz','alina_boz@gmail.com','alina123',1,2,1,1,22)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Fyodor','Dostoyevski','dostoyevski','fyodor_d@gmail.com','fyodor0123',4,1,2,1,60)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Anton','Çehov','çehov_1','a_çehov@gmail.com','çehov321',4,1,1,1,44)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Bülent','Korkmaz','bülentkorkmaz_1905','b_korkmaz@gmail.com','bülent1905',1,1,2,1,52)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Venessa','Paradis','V_Paradis','paradis@gmail.com','paradis123',3,2,1,1,48)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Zinédine','Zidane','ZidaneOnline','zidane@gmail.com','zidane1234',3,1,2,1,48)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Cristiano','Ronaldo','CR7','c_ronaldo@gmail.com','cr7',9,1,1,1,35)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Lionel','Messi','LM10','leomessi@gmail.com','lm10',10,1,2,1,33)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Çaðatay','Ulusoy','c_ulusoy','cagatayulusoy@gmail.com','cgty123',1,1,1,1,30)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Elif','Sadýk','elif123','elif_s@gmail.com','elif123',1,2,1,3,20)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Tuðba','Öztürk','tuðba','tugaba_ozturk@gmail.com','tuðba123',1,2,1,3,21)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('David','Beckham','Bckham10','beckham10@gmail.com','Beckham10',6,1,2,1,45)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Adele','Adkins','adeleOnline','adele@gmail.com','adele123',6,2,1,1,32)
GO

INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Ahmet','Taþçý','a_taþcý','ahmett@gmail.com','ahmet123',1,1,1,2,30)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Faik','Kiraz','f_kiraz','faikk@gmail.com','faik123',1,1,1,2,26)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Samet','Çifter','sametcifter','sematc@gmail.com','samet123',1,1,2,2,29)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Özcan','Kaya','ö_kaya','özcank@gmail.com','ozcan123',1,1,2,2,34)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Esra','Candaþ','esra123','esrac@gmail.com','esra123',1,2,2,1,32)
GO
INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Buse','Çarkýt','buse_c','buse@gmail.com','buse123',1,2,2,2,29)
GO

INSERT INTO [VotingSystem].[Voter]([UserName] ,[UserSurname] ,[UserUsername] ,[UserEmail] ,[UserPassword] ,[UserCountry] ,[UserGender] ,[MaritalStatus] ,[JobStatus] ,[UserAge])
     VALUES ('Ayþe','Köse','ayþe123','ayþe@gmail.com','ayþe123',1,2,1,1,27)
GO
------------------------------------------------------------------------

--VOTE
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(1,1,1,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(1,2,3,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(1,3,5,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(1,4,8,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(1,5,9,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(1,6,12,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(1,7,14,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(1,8,15,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(1,9,18,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(1,10,20,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(1,11,22,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(1,12,24,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(1,13,26,'2020-10-15')
GO
--1st user end--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(2,1,1,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(2,2,3,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(2,3,5,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(2,4,8,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(2,5,9,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(2,6,12,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(2,7,14,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(2,8,15,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(2,9,18,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(2,10,20,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(2,11,22,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(2,12,24,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(2,13,26,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(2,14,27,'2020-10-15')
GO
--2nd user end--


--3 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(3,1,1,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(3,2,4,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(3,4,8,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(3,5,10,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(3,7,14,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(3,8,15,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(3,9,18,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(3,10,20,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(3,11,22,'2020-10-06')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(3,14,28,'2020-10-06')--
GO
--4 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(4,2,4,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(4,3,5,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(4,4,8,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(4,5,10,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(4,7,14,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(4,8,15,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(4,10,20,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(4,14,27,'2020-10-06')--
GO

--5th user end--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(5,4,7,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(5,6,12,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(5,7,14,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(5,8,15,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(5,9,18,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(5,10,20,'2020-10-15')
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(5,14,28,'2020-10-15')
GO

--6th user end--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(6,2,3,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(6,4,8,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(6,5,9,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(6,7,13,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(6,14,28,'2020-10-15')
GO

--7th user end--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(7,1,1,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(7,2,3,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(7,3,6,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(7,4,7,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(7,6,12,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(7,7,14,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(7,8,15,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(7,9,18,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(7,14,27,'2020-10-15')
GO

--8th user end--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(8,2,3,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(8,3,5,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(8,6,12,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(8,7,14,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(8,8,15,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(8,12,24,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(8,14,27,'2020-10-15')
GO

--9th user end--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(9,1,1,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(9,2,3,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(9,3,6,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(9,6,12,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(9,7,14,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(9,14,28,'2020-10-15')
GO

--10th user end--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(10,1,1,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(10,2,3,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(10,3,5,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(10,4,8,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(10,5,9,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(10,6,12,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(10,7,14,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(10,8,15,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(10,9,18,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(10,10,20,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(10,11,22,'2020-10-06')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(10,12,24,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(10,14,27,'2020-10-15')
GO

--11th user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(11,1,1,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(11,2,3,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(11,3,5,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(11,4,8,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(11,5,9,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(11,6,12,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(11,7,14,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(11,8,15,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(11,9,18,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(11,10,20,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(11,11,22,'2020-10-06')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(11,12,24,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(11,14,28,'2020-10-15')
GO

--12 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(12,1,1,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(12,2,3,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(12,3,5,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(12,4,8,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(12,5,9,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(12,6,12,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(12,11,22,'2020-10-06')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(12,12,24,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(12,14,27,'2020-10-15')
GO

--13 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(13,3,5,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(13,4,8,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(13,5,9,'2020-10-15')
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(13,11,22,'2020-10-06')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(13,12,24,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(13,14,28,'2020-10-15')
GO

--14 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(14,1,1,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(14,2,3,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(14,13,26,'2020-10-15')
GO

--user 15--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(15,3,5,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(15,4,7,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(15,10,19,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(15,11,22,'2020-10-06')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(15,12,24,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(15,13,26,'2020-10-15')
GO

--user 16--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(16,1,1,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(16,4,8,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(16,5,9,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(16,6,12,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(16,7,14,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(16,8,15,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(16,9,18,'2020-10-15')
GO

--17 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(17,2,3,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(17,3,6,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(17,4,8,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(17,11,22,'2020-10-06')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(17,12,24,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(17,13,26,'2020-10-15')
GO

--18 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(18,1,1,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(18,2,3,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(18,5,9,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(18,6,12,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(18,7,14,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(18,8,15,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(18,12,24,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(18,13,26,'2020-10-15')
GO

--19 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(19,1,1,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(19,12,24,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(19,13,25,'2020-10-15')
GO

--20 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(20,1,2,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(20,2,4,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(20,3,5,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(20,11,22,'2020-10-06')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(20,12,24,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(20,13,26,'2020-10-15')
GO

--21 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(21,11,21,'2020-10-06')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(21,12,23,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(21,13,25,'2020-10-15')
GO

--22 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(22,1,2,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(22,2,3,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(22,3,6,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(22,4,8,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(22,5,10,'2020-10-15')
GO

--23 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(23,1,2,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(23,5,10,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(23,6,11,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(23,7,13,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(23,8,16,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(23,9,17,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(23,13,25,'2020-10-15')
GO

--24 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(24,2,3,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(24,3,5,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(24,6,12,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(24,7,14,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(24,8,15,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(24,12,24,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(24,13,26,'2020-10-15')
GO

--25 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(25,2,3,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(25,3,5,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(25,5,9,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(25,6,12,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(25,7,14,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(25,8,15,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(25,9,18,'2020-10-15')
GO

--26 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(26,1,1,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(26,4,8,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(26,5,9,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(26,10,20,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(26,11,22,'2020-10-06')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(26,13,26,'2020-10-15')
GO

--27 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(27,1,2,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(27,2,4,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(27,6,11,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(27,7,13,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(27,8,16,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(27,9,17,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(27,13,25,'2020-10-15')
GO

--28 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(28,3,6,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(28,4,8,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(28,5,10,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(28,6,12,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(28,13,25,'2020-10-15')
GO

--29 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(29,1,1,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(29,2,4,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(29,3,5,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(29,4,7,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(29,5,9,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(29,6,11,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(29,13,26,'2020-10-15')
GO

--30 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(30,3,5,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(30,4,7,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(30,5,10,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(30,6,12,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(30,7,13,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(30,13,25,'2020-10-15')
GO

--31 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(31,1,1,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(31,2,4,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(31,5,10,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(31,6,12,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(31,12,24,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(31,13,26,'2020-10-15')
GO

--32 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(32,1,2,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(32,5,9,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(32,6,11,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(32,7,13,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(32,8,16,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(32,9,18,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(32,10,20,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(32,11,21,'2020-10-06')--
GO
--33 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(33,1,1,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(33,2,3,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(33,3,6,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(33,4,7,'2020-10-06')

INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(33,9,18,'2020-10-15')
go
--34 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(34,5,9,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(34,6,11,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(34,7,13,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(34,8,15,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(34,9,18,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(34,10,20,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(34,11,21,'2020-10-06')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(34,12,23,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(34,13,25,'2020-10-15')
GO

----
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(35,1,1,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(35,2,3,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(35,10,20,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(35,11,22,'2020-10-06')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(35,12,24,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(35,13,26,'2020-10-15')
GO

--36 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(36,1,2,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(36,2,4,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(36,3,6,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(36,4,7,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(36,5,10,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(36,6,11,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(36,7,13,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(36,8,16,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(36,11,22,'2020-10-15')
GO
--37 user--
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(37,1,2,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(37,2,4,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(37,3,6,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(37,4,8,'2020-10-06')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(37,5,10,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(37,6,12,'2020-10-15')--
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(37,7,14,'2020-10-15')
GO
INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(37,8,16,'2020-10-15')
GO

INSERT INTO [VotingSystem].[Vote]([User_Key],[Voting_Key],[Option_Key],[VoteDate]) 
VALUES(37,13,26,'2020-10-15')
GO


