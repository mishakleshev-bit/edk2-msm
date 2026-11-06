/*
 * ACPI Battery & Charger SSDT Table for Xiaomi Redmi Note 9 Pro (joyeuse / miatoll)
 * Hardware Platform: Qualcomm Snapdragon 720G (SM7125 / Atoll)
 * Battery: Xiaomi BN53 (5020 mAh / 19.42 Wh, 3870 mV nominal)
 */

DefinitionBlock ("", "SSDT", 2, "XIAOMI", "MIATOLL", 0x00000002)
{
    Scope (\_SB)
    {
        /*
         * =========================================================================
         * 1. Standard ACPI Control Method Battery
         * Compatible with Windows Native Inbox Driver (battc.sys + cmbatt.sys)
         * Battery specifications for Xiaomi Redmi Note 9 Pro (BN53: 5020 mAh / 3870 mV)
         * =========================================================================
         */
        Device (BAT1)
        {
            Name (_HID, EisaId ("PNP0C0A"))
            Name (_UID, 0x01)

            Method (_STA, 0, NotSerialized)
            {
                Return (0x1F) // Device present, enabled, decode, functioning
            }

            /*
             * Battery Information Extended (_BIX) - 20 elements per ACPI spec
             */
            Method (_BIX, 0, NotSerialized)
            {
                Return (Package (20)
                {
                    0x00000000,             // 0: Revision = 0
                    0x00000001,             // 1: Power Unit = 1 (mAh)
                    0x0000139C,             // 2: Design Capacity = 5020 mAh
                    0x0000139C,             // 3: Last Full Charge Capacity = 5020 mAh
                    0x00000001,             // 4: Battery Technology = 1 (Secondary/Rechargeable)
                    0x00000F1E,             // 5: Design Voltage = 3870 mV
                    0x000001F4,             // 6: Design Capacity Warning = 500 mAh (~10%)
                    0x000000FA,             // 7: Design Capacity Low = 250 mAh (~5%)
                    0x00000064,             // 8: Cycle Count
                    0x00017700,             // 9: Measurement Accuracy = 96,000 scale
                    0x00000000,             // 10: Max Sampling Time
                    0x00000000,             // 11: Min Sampling Time
                    0x00000000,             // 12: Max Averaging Interval
                    0x00000000,             // 13: Min Averaging Interval
                    0x00000032,             // 14: Battery Capacity Granularity 1 (50 mAh)
                    0x00000032,             // 15: Battery Capacity Granularity 2 (50 mAh)
                    "BN53",                 // 16: Model Number
                    "1234567890",           // 17: Serial Number
                    "LION",                 // 18: Battery Chemistry
                    "Xiaomi"                // 19: OEM Information
                })
            }

            /*
             * Battery Status (_BST) - 4 elements per ACPI spec
             */
            Method (_BST, 0, NotSerialized)
            {
                Return (Package (4)
                {
                    0x00000002, // 0: State: 1 = Discharging, 2 = Charging
                    0x000007D0, // 1: Present Rate (mA): 2000 mA
                    0x00001000, // 2: Remaining Capacity (mAh): ~4096 mAh (~82%)
                    0x00000F1E  // 3: Present Voltage (mV): 3870 mV
                })
            }
        }

        /*
         * =========================================================================
         * 2. Standard ACPI AC Adapter (Charger / VBUS Detection)
         * Compatible with Windows Native Inbox Driver (acpi.sys)
         * =========================================================================
         */
        Device (ADP1)
        {
            Name (_HID, "ACPI0003")
            Name (_UID, 0x01)
            Name (_PCL, Package () { \_SB.BAT1 })

            Method (_STA, 0, NotSerialized)
            {
                Return (0x0F) // Device present, enabled, functioning
            }

            // Power Source Status: 1 = Online (Plugged in), 0 = Offline (On Battery)
            Method (_PSR, 0, NotSerialized)
            {
                Return (0x01) // Power Online (Plugged in)
            }
        }
    }
}
