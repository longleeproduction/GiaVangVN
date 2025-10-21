#  Giá Vàng


## Trang chủ - giá vàng

Chênh lệch Trong nước và Thế giới
```
https://giavang.pro/diff.html?product=T0FOREE6WEFVVVNE&theme=light
```

Phân tích Kỹ thuật cho XAUUSD
```
https://giavang.pro/technical.html?product=T0FOREE6WEFVVVNE&theme=light
```

BTCUSDT
```
https://giavang.pro/box.html?product=QklOQU5DRTpCVENVU0RU&theme=light
```

USDVND
```
https://giavang.pro/box.html?product=RlhfSURDOlVTRFZORA==&theme=light
```

XAUUSD
```
https://giavang.pro/box.html?product=T0FOREE6WEFVVVNE&theme=light
```

EURUSD
```
https://www.tradingview-widget.com/embed-widget/mini-symbol-overview/?locale=vi_VN
```

Phân tích Kỹ thuật cho AAPL
```
https://www.tradingview-widget.com/embed-widget/technical-analysis/?locale=vi_VN
```


### Request api
```
{
    "lang": "vi",
    "product": "Vàng nhẫn 9999",
    "branch": "SJC",
    "city": "Hồ Chí Minh"
}
```

```
{
    "branch": "SJC",
    "lang": "vi",
    "product": "Vàng miếng SJC",
    "city": "Hồ Chí Minh"
}
```

```
{
    "city": "Hà Nội",
    "product": "Bạc thỏi Phú Quý 999",
    "lang": "vi",
    "branch": "PHUQUY"
}
```

- Bảng giá vàng miếng SJC - vàng nhẫn 999:
```
{
    "city": "Hồ Chí Minh",
    "product": "Vàng miếng SJC",
    "branch": "SJC",
    "lang": "vi"
}
```
```
{
    "branch": "SJC",
    "lang": "vi",
    "city": "Hồ Chí Minh",
    "product": "Vàng nhẫn 9999"
}
```

- Tỷ giá USD của VCB
```
{
    "lang": "vi",
    "branch": "VCB",
    "code": "USD"
}
```

- Biểu đồ vàng miếng SJC - Vàng nhẫn 999
```
{
    "city": "Hồ Chí Minh",
    "product": "Vàng miếng SJC",
    "lang": "vi",
    "branch": "SJC"
}
```
```
{
    "branch": "SJC",
    "city": "Hồ Chí Minh",
    "product": "Vàng nhẫn 9999",
    "lang": "vi"
}
```


## Tab Giá Vàng

- Lấy cấu hình
```
https://giavang.pro/services/v1/gold
```

- Giá hàng ngày daily
```
{
    "lang": "vi",
    "branch": "sjc"
}
```
Branch support: `sjc`, `doji`, `btmc`, `mihong`, `btmh`, `phuquy`, `ngoctham`, `pnj`,

Xem chi tiết biểu đồ vàng:
```
{
    "lang": "vi",
    "product": "Vàng SJC 1L, 10L, 1KG", // Tên sản phẩm từ api daily
    "range": 7,
    "branch": "sjc",
    "city": "Hải Phòng" // Lấy theo api daily trả về city
}
```


- Biểu đồ giá:
```
{
    "city": "Hồ Chí Minh",
    "product": "Vàng miếng SJC",
    "range": 60,
    "lang": "vi",
    "branch": "sjc"
}
```
```
{
    "product": "SJC - Bán Lẻ",
    "branch": "doji",
    "range": 60,
    "lang": "vi",
    "city": " Bảng giá tại Hồ Chí Minh"
}
```


**Vàng thế giới:** `https://giavang.pro/chart.html?product=T0FOREE6WEFVVVNE&theme=light`
**Lịch kinh tế:** `https://giavang.pro/economic.html?product=T0FOREE6WEFVVVNE&theme=light`

## Tab tỷ giá:  

**Lấy cấu hình hiển thị:**
```
https://giavang.pro/services/v1/currency
```
### Request
- Vietcombank danh sách tỷ giá (api daily)
```
{
    "branch": "vcb",
    "lang": "vi"
}
```
**- Branch support:** `vcb`, `bidv`, 


- Biểu đồ Vietcombank (api list)
```
{
    "lang": "vi",
    "branch": "vcb",
    "code": "USD",
    "range": 60
}
```
**- Branch support:** `vcb`, `bidv`, 

- Chi tiết bảng tỷ giá của 1 đồng tiên tại 1 bank(api list)
```
{
    "branch": "vcb",
    "lang": "vi",
    "code": "AUD", // lấy thông tin từ code trong danh sách tỷ giá
    "range": 7
}
```
**- range support:** `7`, `30`, `60`, `180`, `365`, 

**Biểu đồ Forex**
```
https://giavang.pro/chart.html?product=RlhfSURDOlVTRFZORA==&theme=light
```


# Watch App
Sử dụng chung Api folder code và sử dụng chung view model của các dashboard, gold, currency
