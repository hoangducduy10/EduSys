CREATE DATABASE EduSys
GO
USE EduSys
GO
CREATE TABLE NhanVien(
MaNV nvarchar(50) NOT NULL,
MatKhau nvarchar(50) NOT NULL,
HoTen nvarchar(50) NOT NULL,
VaiTro bit NOT NULL DEFAULT 0,
PRIMARY KEY(MaNV)
)
GO
CREATE TABLE ChuyenDe(
MaCD nchar(5) NOT NULL PRIMARY KEY,
TenCD nvarchar(50) NOT NULL,
HocPhi float NOT NULL DEFAULT 0,
ThoiLuong int NOT NULL DEFAULT 30,
Hinh nvarchar(50) NOT NULL ,
MoTa nvarchar(255) NOT NULL,
UNIQUE(TenCD),
CHECK(HocPhi >= 0 AND ThoiLuong > 0)
)
GO
CREATE TABLE NguoiHoc(
MaNH nchar(7) NOT NULL PRIMARY KEY,
HoTen nvarchar(50) NOT NULL,
NgaySinh date NOT NULL,
GioiTinh bit NOT NULL DEFAULT 0,
DienThoai nvarchar(50) NOT NULL,
Email nvarchar(50) NOT NULL,
GhiChu nvarchar(max) NULL,
MaNV nvarchar(50) NOT NULL FOREIGN KEY REFERENCES NhanVien (MaNV),
NgayDK date NOT NULL DEFAULT getdate(),
)
GO
CREATE TABLE KhoaHoc(
MaKH int IDENTITY(1,1) NOT NULL,
MaCD nchar(5) NOT NULL,
HocPhi float NOT NULL DEFAULT 0,
ThoiLuong int NOT NULL DEFAULT 0,
NgayKG date NOT NULL,
GhiChu nvarchar(50) NULL,
MaNV nvarchar(50) NOT NULL,
NgayTao date NOT NULL DEFAULT getdate(),
PRIMARY KEY(MaKH),
CHECK(HocPhi >= 0 AND ThoiLuong > 0),
FOREIGN KEY (MaCD) REFERENCES ChuyenDe(MaCD) ON UPDATE CASCADE,
FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV) ON UPDATE CASCADE
)
GO
CREATE TABLE HocVien(
MaHV int IDENTITY(1,1) NOT NULL,
MaKH int NOT NULL,
MaNH nchar(7) NOT NULL,
Diem float NOT NULL,
PRIMARY KEY(MaHV),
UNIQUE(MaKH, MaNH),
FOREIGN KEY (MaKH) REFERENCES KhoaHoc(MaKH) ON DELETE CASCADE,
FOREIGN KEY (MaNH) REFERENCES NguoiHoc(MaNH) ON UPDATE CASCADE
)












CREATE PROC SP_BangDiem(@MaKH INT)
AS
BEGIN
	SELECT
		NH.MaNH,
		NH.HoTen,
		HV.Diem
	FROM HocVien HV 
	JOIN NguoiHoc NH ON NH.MaNH=HV.MaNH
	WHERE HV.MaKH=@MaKH
	ORDER BY HV.Diem DESC
END



CREATE PROC SP_DiemChuyenDe
AS
BEGIN
	SELECT 
		TenCD ChuyenDe,
		COUNT(MaHV) SoHV,
		MIN(Diem) ThapNhat,
		MAX(Diem) CaoNhat,
		AVG(Diem) TrungBinh
	FROM KhoaHoc KH 
		JOIN HocVien HV ON KH.MaKH=HV.MaKH
		JOIN ChuyenDe CD ON CD.MaCD = KH.MaCD
	GROUP BY TenCD
END



CREATE PROC SP_DoanhThu(@Year INT)
AS
BEGIN
	SELECT
		TenCD ChuyenDe,
		COUNT(DISTINCT KH.MaKH) SoKH,
		COUNT(HV.MaHV) SoHV,
		SUM(KH.HocPhi) DoanhThu,
		MIN(KH.HocPhi) ThapNhat,
		MAX(KH.HocPhi) CaoNhat,
		AVG(KH.HocPhi) TrungBinh
	FROM KhoaHoc KH
		JOIN HocVien HV ON KH.MaKH=HV.MaKH
		JOIN ChuyenDe CD ON CD.MaCD=KH.MaCD
	WHERE YEAR(NgayKG) = @Year
	GROUP BY TenCD
END



CREATE PROC SP_LuongNguoiHoc
AS
BEGIN
	SELECT 
		YEAR(NgayDK) Nam,
		COUNT(*) SoLuong,
		MIN(NgayDK) DauTien,
		MAX(NgayDK) CuoiCung
	FROM NguoiHoc
	GROUP BY YEAR(NgayDK)
END