/*
 * ACPI Battery & Charger Table for Xiaomi Redmi Note 9 Pro (joyeuse / miatoll)
 * Hardware Platform: Qualcomm Snapdragon 720G (SM7125 / Atoll)
 * PMIC: Qualcomm PM6150 (SMB5) & PM6150L
 * Battery: Xiaomi BN53 (5020 mAh / 19.42 Wh)
 */

DefinitionBlock ("", "SSDT", 2, "XIAOMI", "MIATOLL", 0x00000002)
{
    External (\_SB.PM01, DeviceObj)   // Qualcomm SPMI Controller (QCOM0830)
    External (\_SB.PMIC, DeviceObj)   // Qualcomm PMIC Core (QCOM0806)

    Scope (\_SB)
    {
        /*
         * =========================================================================
         * 1. Hardware PMIC Fuel Gauge Driver Node
         * Matches Miatoll-Drivers: PMFG.sys (ACPI\PMFG) by Nikroks
         * Reads battery SOC directly from PM6150 QG SDAM register 0xB668
         * =========================================================================
         */
        Device (PMFG)
        {
            Name (_HID, "PMFG")
            Name (_UID, 0x01)
            Name (_DEP, Package () { \_SB.PM01, \_SB.PMIC })

            Method (_STA, 0, NotSerialized)
            {
                Return (0x0F) // Device present, enabled, decode, functioning
            }

            Method (_CRS, 0, NotSerialized)
            {
                Name (RBUF, ResourceTemplate ()
                {
                    // GenericSerialBus connection to PM01 SPMI controller
                    GenericSerialBus (
                        0x0B,                       // Access type
                        0x00,                       // Slave address
                        0x00000000,                 // Connection speed
                        AddressingMode7Bit,
                        "\\_SB.PM01",
                        0x00,
                        ResourceConsumer,
                        ,
                        Exclusive
                    )
                })
                Return (RBUF)
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
                Return (0x0F)
            }

            // Power Source Status: 1 = Online (Plugged in), 0 = Offline (On Battery)
            Method (_PSR, 0, NotSerialized)
            {
                Return (0x01) // Default to Online when tested
            }
        }

        /*
         * =========================================================================
         * 3. Standard ACPI Control Method Battery
         * Compatible with Windows Native Inbox Driver (battc.sys + cmbatt.sys)
         * Battery specifications for Xiaomi Redmi Note 9 Pro (BN53: 5020 mAh / 3870 mV)
         * =========================================================================
         */
        Device (BAT1)
        {
            Name (_HID, "PNP0C0A")
            Name (_UID, 0x01)

            Method (_STA, 0, NotSerialized)
            {
                Return (0x1F)
            }

            /*
             * Battery Information Extended (_BIX)
             */
            Method (_BIX, 0, NotSerialized)
            {
                Name (BPKG, Package (21)
                {
                    0x00000001,             // 0: Power Unit = 1 (mAh)
                    0x0000139C,             // 1: Design Capacity = 5020 mAh (0x139C)
                    0x0000139C,             // 2: Last Full Charge Capacity = 5020 mAh
                    0x00000001,             // 3: Battery Technology = 1 (Secondary/Rechargeable)
                    0x00000F1E,             // 4: Design Voltage = 3870 mV (0x0F1E)
                    0x000001F4,             // 5: Design Capacity Warning = 500 mAh (~10%)
                    0x000000FA,             // 6: Design Capacity Low = 250 mAh (~5%)
                    0x00000064,             // 7: Cycle Count
                    0x00017700,             // 8: Measurement Accuracy = 96,000 scale
                    0x00000000,             // 9: Max Sampling Time
                    0x00000000,             // 10: Min Sampling Time
                    0x00000000,             // 11: Max Averaging Interval
                    0x00000000,             // 12: Min Averaging Interval
                    0x00000032,             // 13: Battery Capacity Granularity 1 (50 mAh)
                    0x00000032,             // 14: Battery Capacity Granularity 2 (50 mAh)
                    "BN53",                 // 15: Model Number (Redmi Note 9 Pro Battery)
                    "1234567890",           // 16: Serial Number
                    "LION",                 // 17: Battery Chemistry
                    "Xiaomi"                // 18: OEM Information
                })
                Return (BPKG)
            }

            /*
             * Battery Status (_BST)
             */
            Method (_BST, 0, NotSerialized)
            {
                Name (PKG1, Package (4)
                {
                    0x00000002, // 0: State: 1 = Discharging, 2 = Charging
                    0x000007D0, // 1: Present Rate (mA): 2000 mA
                    0x00001000, // 2: Remaining Capacity (mAh): ~4096 mAh
                    0x00000F1E  // 3: Present Voltage (mV): 3870 mV
                })
                Return (PKG1)
            }
        }
    }
}
