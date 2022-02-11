select * from PortfolioProject.dbo.nashville

--Standardize Date Format

select SaleDate, CONVERT(date, SaleDate) from PortfolioProject..nashville

alter table PortfolioProject..nashville add NewSaleDate date

update PortfolioProject..nashville set NewSaleDate = CONVERT(date, SaleDate)

select SaleDate, NewSaleDate from PortfolioProject..nashville

--Populate Property Address

select PropertyAddress from PortfolioProject..nashville
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(b.PropertyAddress, a.PropertyAddress)
from PortfolioProject..nashville a
join PortfolioProject..nashville b
on a.ParcelID = b.ParcelID and b.PropertyAddress is null and a.PropertyAddress is not null

Update PortfolioProject..nashville set PropertyAddress = ISNULL(PortfolioProject..nashville.PropertyAddress, a.PropertyAddress)
from PortfolioProject..nashville a
join PortfolioProject..nashville
on a.ParcelID = PortfolioProject..nashville.ParcelID and PortfolioProject..nashville.PropertyAddress is null and a.PropertyAddress is not null

select PropertyAddress from PortfolioProject..nashville where PropertyAddress is null

--Breaking out Address into Individual Columns (Adderss, City, State)

select SUBSTRING(PropertyAddress, 1, charindex(',',PropertyAddress)-1) as Address
from PortfolioProject..nashville

select SUBSTRING(PropertyAddress, charindex(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
from PortfolioProject..nashville

alter table PortfolioProject..nashville
add PropertySplitAddress varchar(255)

update PortfolioProject..nashville
set PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, charindex(',',PropertyAddress)-1)

alter table PortfolioProject..nashville
add PropertySplitCity varchar(255)

update PortfolioProject..nashville
set PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',',PropertyAddress)+1, LEN(PropertyAddress))

select * from PortfolioProject..nashville

select OwnerAddress from PortfolioProject..nashville

select PARSENAME(replace(OwnerAddress, ',', '.'), 1),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 3)
from PortfolioProject..nashville

alter table PortfolioProject..nashville
add OwnerSplitState varchar(255)


update PortfolioProject..nashville
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

alter table PortfolioProject..nashville
add OwnerSplitCity varchar(255)

update PortfolioProject..nashville
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

alter table PortfolioProject..nashville
add OwnerSplitAddress varchar(255)

update PortfolioProject..nashville
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

select * from PortfolioProject..nashville

--Change Y and N to Yes and No in SoldAsVacant field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..nashville
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from PortfolioProject..nashville

update PortfolioProject..nashville set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end

--Identifying all the Duplicates

with RowNumCTE as
(
select *, ROW_NUMBER() over (partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
order by UniqueID) as row_number from PortfolioProject..nashville
)
select * from RowNumCTE
where row_number > 1






