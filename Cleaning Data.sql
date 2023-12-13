/*
   Cleaning data in SQL Queries
*/
Select *
From Portfolioproject..housing

--Standardize Date Format
Select SaleDate, convert(varchar, SaleDate, 23) as SaleDateConverted from housing 

--Populate Property Address Data
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolioproject..housing a
Join Portfolioproject..housing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolioproject..housing a
Join Portfolioproject..housing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking Out PropertyAdrress Into Individual Columns(PhysicalAdress, City)
Select PropertyAddress
From Portfolioproject..housing

Select 
Substring(PropertyAddress, 1, Charindex(',', PropertyAddress)-1) as PhysicalAddress
,Substring(PropertyAddress, Charindex(',', PropertyAddress)+1, Len(PropertyAddress)) as City 
From Portfolioproject..housing

--Count Yes and No in "Sold As Vacant" field and Change some of Y = Yes N = No in "Sold As Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolioproject..housing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From Portfolioproject..housing

Update housing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
--Remove Duplicates
With RowNumCTE As(
Select *,
  Row_Number() Over(
  Partition By ParcelID,
               PropertyAddress,
			   SaleDate,
			   SalePrice,
			   LegalReference
			   Order By
			     UniqueID
				 ) row_num          
From Portfolioproject..housing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--Delete Unused Columns
Select *
From Portfolioproject..housing

Alter Table Portfolioproject..housing
Drop Column OwnerAddress, TaxDistrict







