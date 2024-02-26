--Viewing my cute data lol
Select *
From NashVilleHousing 

--i ll change the date format cause it is not 'pretty'
Select Saledate
From NashVilleHousing

--EXEC sp_columns @table_name = 'NashVilleHousing', @column_name = 'Saledate'  (result at first it was datetime)
--ALTER TABLE nashvilleHousing
--ALTER COLUMN Saledate Date     (now result is only date)
--OR autre methode : 
----Update NashVilleHousing
----Set SaleDate = Convert(Date,SaleDate)

------Populate PropertyAddress data
Select *
From NashVilleHousing
--WHere PropertyAddress is null
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
From NashVilleHousing a
JOIN NashVilleHousing b
	On a.ParcelID=b.ParcelID 
	And a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

--Now since the same parcels (but different uniqueID) have same propertyadress, we can put the same address
Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) FinalPropertyAddress
From NashVilleHousing a
JOIN NashVilleHousing b
	On a.ParcelID=b.ParcelID 
	And a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

--Now lets update the whole table
UPDATE a
Set a.PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashVilleHousing a
JOIN NashVilleHousing b
	On a.ParcelID=b.ParcelID 
	And a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

------ Splitiing the address into individual coluns (address, city, state)
Select PropertyAddress
From NashVilleHousing 

Select 
substring(PropertyAddress , 1, charindex(',',PropertyAddress) -1) Address,
substring(PropertyAddress, charindex(',',PropertyAddress) +1, len(PropertyAddress)) City
From NashVilleHousing 
--Now Lets add these columns to our main table
Alter Table NashVilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashVilleHousing
Set PropertySplitAddress=substring(PropertyAddress , 1, charindex(',',PropertyAddress) -1) 

Alter Table NashVilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashVilleHousing
Set PropertySplitCity=substring(PropertyAddress, charindex(',',PropertyAddress) +1, len(PropertyAddress))

----Change Y and N to Yes and No in 'Sold as vacant' field
Select SoldAsVacant,
	Case 
		When SoldAsVacant='Y'Then 'Yes'
		When SoldAsVacant='N' Then 'No'
		ELSE SoldAsVacant
	End
From NashVilleHousing

--now lets update our table
Update NashVilleHousing
Set SoldAsVacant=	Case 
		When SoldAsVacant='Y'Then 'Yes'
		When SoldAsVacant='N' Then 'No'
		ELSE SoldAsVacant
	End
From NashVilleHousing

----REMOVE DUBLICATES 

--so this query is to find the duplicates, if the row_num = 2 it means its the same as the previous row
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order by UniqueID
				 ) row_num

From NashVilleHousing
Order By ParcelID

--now lets create a cte so we can see all those duplicates then DELETE them

With RowNumCTE AS(
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order by UniqueID
				 ) row_num

From NashVilleHousing
--Order By ParcelID
)
Delete --Select* if u want to see the duplicates
From RowNumCTE
Where row_num>1
