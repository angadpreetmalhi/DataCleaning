Select *
From portfolio_project.dbo.housing

--Clean Property address 
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.propertyaddress, b.PropertyAddress)
From housing a
join housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
Set PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
From housing a
join housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

-- Filter SaleDate

Select SaleDate
from housing

Select SaleDate, Convert(Date,SaleDate)
From housing

Update housing
Set SaleDate= Convert(Date,SaleDate)

Alter Table Housing
Add UpdatedSale Date;

Update housing
Set UpdatedSale = Convert(Date,SaleDate)


--Split PropertyAddress

Select PropertyAddress
From housing

Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(propertyAddress))
From housing

Alter Table housing
Add SplitPropertyAddress Nvarchar(255);

update housing
Set SplitpropertyAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter Table housing
Add SplitCityAddress Nvarchar(255);

update housing
Set SplitCityAddress = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(propertyAddress))

--Clean and split owner address
Select ownerAddress
from housing

Select 
PARSEname(REPLACE(OwnerAddress,',','.'),3) as OwnerSteetAddress,
PARSEname(REPLACE(OwnerAddress,',','.'),2) as OwnerCityAddress,
PARSEname(REPLACE(OwnerAddress,',','.'),1) as OwnerStateAddress 
from housing


Alter Table housing
Add OwnerStreetAddress Nvarchar(255);
update housing
Set OwnerStreetAddress  = PARSEname(REPLACE(OwnerAddress,',','.'),3)

Alter Table housing
Add OwnerCityAddress Nvarchar(255);
update housing
Set OwnerCityAddress  = PARSEname(REPLACE(OwnerAddress,',','.'),2)


Alter Table housing
Add OwnerStateAddress Nvarchar(255);
update housing
Set OwnerStateAddress  = PARSEname(REPLACE(OwnerAddress,',','.'),1)


-- clean sold and vaccant property
Select SoldAsVacant
From housing

select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
from housing
group by soldAsVacant
order by 2


Select SoldAsVacant, 
Case when SoldAsVacant ='Y' then 'Yes'
	when SoldAsVacant ='N' then 'No'
	Else SoldAsVacant
	end
From housing

update housing
Set SoldAsVacant= Case when SoldAsVacant ='Y' then 'Yes'
	when SoldAsVacant ='N' then 'No'
	Else SoldAsVacant
	end

	-- Delete duplicate rows
with cte_rowNumber as(
Select *, ROW_NUMBER() over (Partition by 
				parcelid , propertyaddress,saleprice,saleDate,legalReference order by uniqueid) rowNum


From housing
)
Delete
from cte_rowNumber
where rowNum>1

--delete unsued columns
Alter table housing
drop column owneraddress,taxdistrict,propertyaddress, saledate

 Alter table housing
 drop column Splitaddress,ownersteetaddress