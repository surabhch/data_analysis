/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProject.dbo.NashvilleHousingData

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select saleDate 
From PortfolioProject.dbo.NashvilleHousingData

Select saleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousingData

Update NashvilleHousingData
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousingData
Add SaleDateConverted Date;

Update NashvilleHousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousingData
---Where PropertyAddress is null
order by ParcelID

----We can see that for some property address , the values is null. if we try to compare the parcel ID , we can see it is matching for some rows where property address is present.
---We can use this to self join on parcel id and make sure that the unique id is different to find addresses for the missing property address values.

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousingData a
JOIN PortfolioProject.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Select a.PropertyAddress , a.ParcelID , b.PropertyAddress , b.ParcelID , ISNULL(a.PropertyAddress,b.PropertyAddress)
From  PortfolioProject.dbo.NashvilleHousingData a
join  PortfolioProject.dbo.NashvilleHousingData b
      on a.ParcelID = b.ParcelID
	  AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

SELECT * 
From  PortfolioProject.dbo.NashvilleHousingData
Where ParcelID LIKE	'052 01 0 296.00%'


--update the value in property address using above query

----SET PropertyAddress = ISNULL(a.PropertyAddress,No Address) - can also be populated with any string.

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousingData a
JOIN PortfolioProject.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousingData
--Where PropertyAddress is null
--order by ParcelID


---here the -1 and +1 are added to ignore the comma in the address

---without -1 and +1
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)  ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)  , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousingData

-- correcting the mistake
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousingData

---To add the substrings as new columns in the table - 1) create a new column 2) add data using above substring query
ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From PortfolioProject.dbo.NashvilleHousingData




 

---Parsename is an easier method to get substrings but parse will only work with '.' instead of ',', so we have to replace ',' with '.' in the string

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousingData

Select
PARSENAME(REPLACE(OwnerAddress , ',' , '.'),1)
From PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NashvilleHousingData




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT SoldAsVacant
From PortfolioProject.dbo.NashvilleHousingData

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousingData
Group by SoldAsVacant
order by 2


ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ALTER COLUMN SoldAsVacant varchar(255);

Select SoldAsVacant
, CASE When SoldAsVacant = '1' THEN 'Yes'
	   When SoldAsVacant = '0' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousingData


Update PortfolioProject.dbo.NashvilleHousingData
SET SoldAsVacant = CASE When SoldAsVacant = '1' THEN 'Yes'
	   When SoldAsVacant = '0' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousingData
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------



















