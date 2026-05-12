CREATE PROCEDURE sp_RegisterContract
    @HoTen NVARCHAR(100),
    @SoCCCD VARCHAR(20),
    @SoTienGoc DECIMAL(18,2),
    @Deadline1 DATETIME,
    @Deadline2 DATETIME,
    @ListTaiSan NVARCHAR(MAX) -- Chuỗi JSON: '[{"TenTS":"Xe","GiaTri":15000000},...]'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1. Xử lý Khách hàng (Nếu chưa có thì thêm mới)
        DECLARE @MaKH INT;
        SELECT @MaKH = MaKH FROM KhachHang WHERE SoCCCD = @SoCCCD;
        
        IF @MaKH IS NULL
        BEGIN
            INSERT INTO KhachHang (HoTen, SoCCCD) VALUES (@HoTen, @SoCCCD);
            SET @MaKH = SCOPE_IDENTITY();
        END

        -- 2. Tạo Hợp đồng
        DECLARE @MaHD INT;
        INSERT INTO HopDong (MaKH, SoTienGoc, NgayVay, Deadline1, Deadline2, TrangThai)
        VALUES (@MaKH, @SoTienGoc, GETDATE(), @Deadline1, @Deadline2, N'Đang vay');
        SET @MaHD = SCOPE_IDENTITY();

        -- 3. Thêm danh sách tài sản từ JSON
        INSERT INTO TaiSan (MaHD, TenTaiSan, GiaTriUocTinh)
        SELECT @MaHD, TenTS, GiaTri
        FROM OPENJSON(@ListTaiSan)
        WITH (
            TenTS NVARCHAR(200) '$.TenTS',
            GiaTri DECIMAL(18,2) '$.GiaTri'
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;

CREATE FUNCTION fn_CalcMoneyContract
(
    @ContractID INT,
    @TargetDate DATETIME
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Goc DEC IMAL(18,2), @NgayVay DATETIME, @D1 DATETIME;
    DECLARE @Total DECIMAL(18,2) = 0;
    DECLARE @r DECIMAL(18,4) = 0.005; -- 0.5% mỗi ngày
    -- Lấy thông tin gốc
    SELECT @Goc = SoTienGoc, @NgayVay = NgayVay, @D1 = Deadline1 
    FROM HopDong WHERE MaHD = @ContractID;
    -- Nếu ngày tính toán trước khi vay thì trả về 0
    IF @TargetDate < @NgayVay RETURN 0;
    -- 1. Tính số ngày giai đoạn lãi đơn (trước hoặc bằng Deadline1)
    DECLARE @DaysSimple INT;
    IF @TargetDate <= @D1
        SET @DaysSimple = DATEDIFF(DAY, @NgayVay, @TargetDate);
    ELSE
        SET @DaysSimple = DATEDIFF(DAY, @NgayVay, @D1);
    DECLARE @MoneyAtD1 DECIMAL(18,2) = @Goc + (@Goc * @r * @DaysSimple);
    -- 2. Tính lãi kép nếu quá Deadline1
    IF @TargetDate > @D1
    BEGIN
        DECLARE @DaysCompound INT = DATEDIFF(DAY, @D1, @TargetDate);
        SET @Total = @MoneyAtD1 * POWER((1 + @r), @DaysCompound);
    END
    ELSE
    BEGIN
        SET @Total = @MoneyAtD1;
    END
    RETURN @Total;
END;

CREATE FUNCTION fn_CalcMoneyTransaction
(
    @ContractID INT,
    @TargetDate DATETIME
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @TongNo DECIMAL(18,2);
    DECLARE @Goc DECIMAL(18,2);
    
    SELECT @Goc = SoTienGoc FROM HopDong WHERE MaHD = @ContractID;
    SET @TongNo = dbo.fn_CalcMoneyContract(@ContractID, @TargetDate);
    
    -- Trả về phần chênh lệch (Lãi đơn + Lãi kép)
    RETURN @TongNo - @Goc;
END;

-- Sử dụng đúng database của bạn
USE Qlycamdo;
GO

-- 1. Tạo bảng Khách hàng
CREATE TABLE KhachHang (
    MaKH INT PRIMARY KEY IDENTITY(1,1),
    HoTen NVARCHAR(100) NOT NULL,
    SoCCCD VARCHAR(20) UNIQUE,
    SDT VARCHAR(15)
);

-- 2. Tạo bảng Hợp đồng
CREATE TABLE HopDong (
    MaHD INT PRIMARY KEY IDENTITY(1,1),
    MaKH INT FOREIGN KEY REFERENCES KhachHang(MaKH),
    NgayVay DATETIME DEFAULT GETDATE(),
    SoTienGoc DECIMAL(18,2),
    Deadline1 DATETIME,
    TrangThai NVARCHAR(50)
);
-- 3. Tạo bảng Tài sản
CREATE TABLE TaiSan (
    MaTS INT PRIMARY KEY IDENTITY(1,1),
    MaHD INT FOREIGN KEY REFERENCES HopDong(MaHD),
    TenTaiSan NVARCHAR(200),
    GiaTriUocTinh DECIMAL(18,2)
);
GO

-- 1. Thêm khách hàng
INSERT INTO KhachHang (HoTen, SoCCCD, SDT) 
VALUES (N'Nguyễn Văn A', '0123456789', '0909123456');
DECLARE @MaKH INT = SCOPE_IDENTITY();
-- 2. Thêm hợp đồng (Vay 10 triệu, Deadline1 là 11/05)
INSERT INTO HopDong (MaKH, SoTienGoc, NgayVay, Deadline1, TrangThai)
VALUES (@MaKH, 10000000, '2026-05-01', '2026-05-11', N'Đang vay');
DECLARE @MaHD INT = SCOPE_IDENTITY();
-- 3. Thêm tài sản
INSERT INTO TaiSan (MaHD, TenTaiSan, GiaTriUocTinh)
VALUES (@MaHD, N'Xe Honda Vision', 25000000);
-- Kiểm tra kết quả vừa thêm
SELECT * FROM KhachHang;
SELECT * FROM HopDong;
SELECT * FROM TaiSan;


-- Giả sử ID hợp đồng là 1
DECLARE @TestID INT = 1;

SELECT 
    N'Trước Deadline 1 (Lãi đơn)' AS GiaiDoan,
    '2026-05-06' AS NgayKiemTra,
    dbo.fn_CalcMoneyContract(@TestID, '2026-05-06') AS TongNo_PhaiTra

UNION ALL

SELECT 
    N'Đúng ngày Deadline 1' AS GiaiDoan,
    '2026-05-11' AS NgayKiemTra,
    dbo.fn_CalcMoneyContract(@TestID, '2026-05-11') AS TongNo_PhaiTra

UNION ALL

SELECT 
    N'Sau Deadline 1 (Lãi kép - 2 ngày)' AS GiaiDoan,
    '2026-05-13' AS NgayKiemTra,
    dbo.fn_CalcMoneyContract(@TestID, '2026-05-13') AS TongNo_PhaiTra;


USE Qlycamdo;
GO
CREATE OR ALTER PROCEDURE sp_ProcessPayment
    @MaHD INT,
    @SoTienTra DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CurrentDate DATETIME = GETDATE();
    DECLARE @TongNo DECIMAL(18,2);
    DECLARE @Deadline2 DATETIME;
    DECLARE @IsSold BIT;
    -- 1. Lấy thông tin thanh lý và hạn Deadline 2
    SELECT @Deadline2 = Deadline2, @IsSold = IsSold 
    FROM HopDong WHERE MaHD = @MaHD;
    -- 2. Kiểm tra nếu đã thanh lý sau Deadline 2
    IF @CurrentDate > @Deadline2 AND @IsSold = 1
    BEGIN
        PRINT N'Tài sản đã bị thanh lý. Không thu tiền, không trả đồ.';
        RETURN;
    END
    -- 3. Tính nợ và xử lý (Phần này gọi lại Function của Event 2)
    SET @TongNo = dbo.fn_CalcMoneyContract(@MaHD, @CurrentDate);
    PRINT N'Tổng nợ hiện tại: ' + CAST(@TongNo AS NVARCHAR(20));
    PRINT N'Số tiền khách trả: ' + CAST(@SoTienTra AS NVARCHAR(20));
    -- Cập nhật trạng thái
    IF @SoTienTra >= @TongNo
        UPDATE HopDong SET TrangThai = N'Đã thanh toán đủ' WHERE MaHD = @MaHD;
    ELSE
        UPDATE HopDong SET TrangThai = N'Đang trả góp' WHERE MaHD = @MaHD;
    PRINT N'Giao dịch thành công!';
END;
GO

SELECT MaHD, SoTienGoc, TrangThai 
FROM HopDong 
WHERE MaHD = 1;
-- Gọi procedure để trả 2 triệu
EXEC sp_ProcessPayment @MaHD = 1, @SoTienTra = 2000000;


SELECT * FROM HopDong WHERE MaHD = 1;

USE Qlycamdo;
GO

CREATE TABLE Log (
    MaLog INT PRIMARY KEY IDENTITY(1,1),
    MaHD INT FOREIGN KEY REFERENCES HopDong(MaHD),
    NgayBienDong DATETIME DEFAULT GETDATE(),
    SoTienGiaoDich DECIMAL(18,2),
    DuNoConLai DECIMAL(18,2),
    GhiChu NVARCHAR(500)
);
GO
CREATE OR ALTER PROCEDURE sp_ProcessPayment
    @MaHD INT,
    @SoTienTra DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CurrentDate DATETIME = GETDATE();
    DECLARE @TongNo DECIMAL(18,2) = dbo.fn_CalcMoneyContract(@MaHD, @CurrentDate);

    -- Lệnh ghi vào bảng Log
    INSERT INTO Log (MaHD, NgayBienDong, SoTienGiaoDich, DuNoConLai, GhiChu)
    VALUES (@MaHD, @CurrentDate, @SoTienTra, (@TongNo - @SoTienTra), N'Khách trả tiền');

    -- Cập nhật trạng thái hợp đồng
    IF @SoTienTra >= @TongNo
        UPDATE HopDong SET TrangThai = N'Đã thanh toán đủ' WHERE MaHD = @MaHD;
    ELSE
        UPDATE HopDong SET TrangThai = N'Đang trả góp' WHERE MaHD = @MaHD;

    PRINT N'Giao dịch thành công và đã ghi log!';
END;
GO

SELECT * FROM Log WHERE MaHD = 1; 


USE Qlycamdo;
GO

-- Tạo View để quản lý danh sách nợ xấu dễ dàng hơn
CREATE OR ALTER VIEW v_BadDebtList AS
SELECT 
    kh.HoTen AS [Tên KH],
    kh.SDT AS [Số điện thoại],
    hd.SoTienGoc AS [Số tiền vay gốc],
    -- Tính số ngày quá hạn từ mốc Deadline 1 đến ngày hôm nay
    DATEDIFF(DAY, hd.Deadline1, GETDATE()) AS [Số ngày quá hạn],
    -- Gọi hàm Event 2 để tính tổng nợ (Gốc + Lãi) hiện tại
    dbo.fn_CalcMoneyContract(hd.MaHD, GETDATE()) AS [Tổng tiền phải trả hiện tại],
    -- Dự báo nợ sau 30 ngày (Dùng hàm lãi kép lũy thừa 30 ngày tới)
    dbo.fn_CalcMoneyContract(hd.MaHD, DATEADD(MONTH, 1, GETDATE())) AS [Tổng số tiền sau 1 tháng nữa]
FROM KhachHang kh
JOIN HopDong hd ON kh.MaKH = hd.MaKH
WHERE hd.Deadline1 < GETDATE() -- Điều kiện 1: Đã quá hạn mốc lãi đơn
  AND hd.TrangThai NOT IN (N'Đã thanh toán đủ', N'Đã thanh lý tài sản'); -- Điều kiện 2: Vẫn còn nợ
GO

UPDATE HopDong 
SET Deadline1 = '2026-04-01', 
    TrangThai = N'Quá hạn (nợ xấu)' 
WHERE MaHD = 1;

SELECT * FROM v_BadDebtList;

CREATE OR ALTER TRIGGER trg_CheckDeadline1
ON HopDong
AFTER UPDATE, INSERT -- Kiểm tra mỗi khi thêm mới hoặc cập nhật hợp đồng
AS
BEGIN
    UPDATE HopDong
    SET TrangThai = N'Quá hạn (nợ xấu)'
    FROM HopDong hd
    JOIN inserted i ON hd.MaHD = i.MaHD
    WHERE hd.TrangThai = N'Đang vay' 
      AND GETDATE() > hd.Deadline1;
END;
GO


-- Thêm cột trạng thái cho tài sản nếu chưa có
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('TaiSan') AND name = 'TrangThaiTS')
    ALTER TABLE TaiSan ADD TrangThaiTS NVARCHAR(50) DEFAULT N'Đang cầm cố';
GO

CREATE OR ALTER TRIGGER trg_ReadyToSell
ON HopDong
AFTER UPDATE
AS
BEGIN
    -- Nếu hợp đồng quá Deadline 2, cập nhật trạng thái tài sản
    UPDATE TaiSan
    SET TrangThaiTS = N'Sẵn sàng thanh lý'
    FROM TaiSan ts
    JOIN inserted i ON ts.MaHD = i.MaHD
    WHERE i.TrangThai = N'Quá hạn (nợ xấu)' 
      AND GETDATE() > i.Deadline2;
END;
GO

CREATE OR ALTER TRIGGER trg_SoldAsset
ON HopDong
AFTER UPDATE
AS
BEGIN
    IF UPDATE(TrangThai) -- Chỉ chạy khi cột TrangThai bị thay đổi
    BEGIN
        UPDATE TaiSan
        SET TrangThaiTS = N'Đã bán thanh lý'
        FROM TaiSan ts
        JOIN inserted i ON ts.MaHD = i.MaHD
        WHERE i.TrangThai = N'Đã thanh lý';
    END
END;
GO


UPDATE HopDong SET Deadline1 = '2026-04-01' WHERE MaHD = 1;
SELECT TrangThai FROM HopDong WHERE MaHD = 1; 

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('TaiSan') AND name = 'TrangThaiTS')
    ALTER TABLE TaiSan ADD TrangThaiTS NVARCHAR(50) DEFAULT N'Đang cầm cố';
GO

UPDATE HopDong 
SET 
    TrangThai = N'Quá hạn (nợ xấu)', 
    Deadline2 = '2026-05-01' -- Chỉnh về quá khứ để quá hạn Deadline 2
WHERE MaHD = 1;

SELECT MaTS, TenTaiSan, TrangThaiTS 
FROM TaiSan 
WHERE MaHD = 1;


UPDATE HopDong SET TrangThai = N'Đã thanh lý' WHERE MaHD = 1;
SELECT TrangThaiTS FROM TaiSan WHERE MaHD = 1;

USE Qlycamdo;
GO
CREATE OR ALTER PROCEDURE sp_RenewContract
    @MaHD INT,
    @SoNgayGiaHan INT -- Số ngày muốn dời thêm Deadline
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CurrentDate DATETIME = GETDATE();
    DECLARE @TienLaiHienTai DECIMAL(18,2);
    -- 1. Tính số tiền lãi khách phải đóng để được gia hạn (Lấy Tổng nợ - Gốc)
    SET @TienLaiHienTai = dbo.fn_CalcMoneyTransaction(@MaHD, @CurrentDate);
    IF @TienLaiHienTai > 0
    BEGIN
        -- 2. Cập nhật Deadline mới (Dời cả D1 và D2)
        UPDATE HopDong
        SET Deadline1 = DATEADD(DAY, @SoNgayGiaHan, Deadline1),
            Deadline2 = DATEADD(DAY, @SoNgayGiaHan, Deadline2),
            NgayVay = @CurrentDate -- Cập nhật lại ngày vay để tính lãi đơn từ đầu cho kỳ mới
        WHERE MaHD = @MaHD;
        -- 3. Ghi vào bảng Log (Audit Log) theo yêu cầu
        -- Tránh việc ghi đè gây mất dấu vết dòng tiền
        INSERT INTO Log (MaHD, NgayBienDong, SoTienGiaoDich, GhiChu)
        VALUES (@MaHD, @CurrentDate, @TienLaiHienTai, 
                N'Gia hạn thêm ' + CAST(@SoNgayGiaHan AS NVARCHAR(10)) + N' ngày. Đã thu lãi.');
        PRINT N'Gia hạn thành công. Khách đã đóng lãi: ' + CAST(@TienLaiHienTai AS NVARCHAR(20));
    END
    ELSE
    BEGIN
        PRINT N'Hợp đồng chưa phát sinh lãi hoặc không tồn tại.';
    END
END;
GO

-- Gia hạn hợp đồng số 1 thêm 10 ngày
EXEC sp_RenewContract @MaHD = 1, @SoNgayGiaHan = 10;

SELECT * FROM Log WHERE MaHD = 1;

SELECT MaTS, TenTaiSan, TrangThaiTS FROM TaiSan WHERE MaHD = 1;



