package license

// Watermark metadata yang disuntikkan secara dinamis saat diunduh dari LMS NgertiKode.
// Informasi ini adalah tanda tangan hak cipta dan jejak kepemilikan resmi pembeli.
var (
	WatermarkOwner       = "Muhammad Alief Nur Hidayah Rani"
	WatermarkEmail       = "aliefrani4@gmail.com"
	WatermarkOrderID     = "INV-20260901141743-9F0BDDDEC7"
	WatermarkFingerprint = "1a00c81c89a933fa526339515dd6f9ee54e136b8ecd3c1f040f16e9ac2eda53b"
)

type WatermarkInfo struct {
	Owner       string `json:"owner"`
	Email       string `json:"email"`
	OrderID     string `json:"order_id"`
	Fingerprint string `json:"fingerprint"`
	IsBound     bool   `json:"is_bound"`
}

// GetWatermark mengembalikan informasi kepemilikan lisensi yang tertanam di source code.
func GetWatermark() WatermarkInfo {
	isBound := WatermarkOwner != "{{LICENSE_"+"OWNER}}" && WatermarkEmail != "{{LICENSE_"+"EMAIL}}"
	return WatermarkInfo{
		Owner:       WatermarkOwner,
		Email:       WatermarkEmail,
		OrderID:     WatermarkOrderID,
		Fingerprint: WatermarkFingerprint,
		IsBound:     isBound,
	}
}
