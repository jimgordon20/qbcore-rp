const { createApp, ref, onMounted } = Vue;

const app = createApp({
    setup() {
        const showAll = ref(false);
        // money
        const cash = ref(0);
        const bank = ref(0);
        const amount = ref(0);
        const plus = ref(false);
        const minus = ref(false);
        const showUpdate = ref(false);
        const showCash = ref(false);
        const showBank = ref(false);
        // player hud
        const health = ref(100);
        const armor = ref(100);
        const hunger = ref(100);
        const thirst = ref(100);
        const stress = ref(0);
        const voice = ref(2.5);
        const talking = ref(false);
        // vehicle
        const speed = ref(0);
        const vehHealth = ref(1000);
        const vehMaxHealth = ref(1000);
        const fuel = ref(100);
        const fuelgauge = ref(100);
        const acceleration = ref(0);
        const rpm = ref(0);
        const vehGear = ref(1);
        const seatbelt = ref(false);
        const cruise = ref(false);
        const showSpeedometer = ref(false);
        // weapon
        const ammoClip = ref(0);
        const ammoBag = ref(0);
        const showWeapon = ref(false);
        // Color properties
        const talkingColor = ref("#FFFFFF");
        const healthColor = ref("#3FA554");
        const armorColor = ref("#326dbf");
        const hungerColor = ref("#dd6e14");
        const thirstColor = ref("#1a7cad");
        const fuelColor = ref("#FFFFFF");
        const engineColor = ref("#FFFFFF");

        function formatMoney(value) {
            const formatter = new Intl.NumberFormat("en-US", {
                style: "currency",
                currency: "USD",
                minimumFractionDigits: 0,
            });
            let money = formatter.format(value);
            let parts = money.split("$");
            return parts[0] + '<span id="sign">$ </span>' + parts[1];
        }

        function handleVisibility(refName, show, duration) {
            if (refName.timeoutId) clearTimeout(refName.timeoutId);
            refName.value = show;
            if (show) {
                refName.timeoutId = setTimeout(() => {
                    refName.value = false;
                }, duration);
            }
        }

        function updateHudData(newhealth, newarmor, newhunger, newthirst, newstress, playerDead) {
            showAll.value = true;

            if (newhealth !== undefined) {
                health.value = newhealth;
                healthColor.value = playerDead ? "#ff0000" : "#3FA554";
                if (playerDead) health.value = 100;
            }

            if (newarmor !== undefined) {
                armor.value = newarmor;
                armorColor.value = newarmor <= 0 ? "#FF0000" : "#326dbf";
            }

            if (newhunger !== undefined) {
                hunger.value = newhunger;
                hungerColor.value = newhunger <= 30 ? "#ff0000" : "#dd6e14";
            }

            if (newthirst !== undefined) {
                thirst.value = newthirst;
                thirstColor.value = newthirst <= 30 ? "#ff0000" : "#1a7cad";
            }

            if (newstress !== undefined) {
                stress.value = newstress;
            }
        }

        function UpdateMoney(cashAmount, bankAmount, amount, isMinus, type) {
            amount.value = amount;
            if (isMinus) {
                minus.value = true;
            } else {
                plus.value = true;
            }
            if (type === "cash") {
                cash.value = formatMoney(cashAmount);
                handleVisibility(showCash, true, 2000);
            } else if (type === "bank") {
                bank.value = formatMoney(bankAmount);
                handleVisibility(showBank, true, 2000);
            }
            handleVisibility(showUpdate, true, 2000);
        }

        function ShowCashAmount(amount) {
            if (amount !== undefined) {
                cash.value = formatMoney(amount);
                handleVisibility(showCash, true, 2000);
            }
        }

        function ShowBankAmount(amount) {
            if (amount !== undefined) {
                bank.value = formatMoney(amount);
                handleVisibility(showBank, true, 2000);
            }
        }

        function ShowSpeedometer(bool) {
            showSpeedometer.value = bool;
        }

        function setSpeed(mph) {
            let rotate = (mph / 150) * (145 - -42) - 42;
            const needle = document.querySelector(".speedometer .needle");
            if (needle) {
                needle.style.transform = `translate(-100%, -50%) rotate(${rotate}deg)`;
            }

            const speedStrokeDasharrayMinMax = [0, 51.5];
            const speedStrokeDasharray = (mph / 150) * (speedStrokeDasharrayMinMax[1] - speedStrokeDasharrayMinMax[0]) + speedStrokeDasharrayMinMax[0];
            const speedPercentageCircle = document.querySelector(".speedometer .speed-percentage .circle");
            if (speedPercentageCircle) {
                speedPercentageCircle.style.strokeDasharray = `${speedStrokeDasharray}, 100`;
            }
        }

        function UpdateVehicleStats(speedAmount, fuelAmount, healthAmount, maxhealthAmount, accelerationAmount, rpmAmount, gearAmount) {
            speed.value = Math.floor(speedAmount);
            fuel.value = Math.floor(fuelAmount);
            vehHealth.value = Math.floor(healthAmount / 10) + "%";
            vehMaxHealth.value = Math.floor(maxhealthAmount);
            acceleration.value = Math.floor(accelerationAmount);
            rpm.value = rpmAmount;

            if (speed.value < 0) {
                vehGear.value = "R";
            } else {
                vehGear.value = gearAmount > 0 ? gearAmount - 1 : gearAmount;
            }

            setSpeed(speed.value);

            const fuelStrokeDasharrayMinMax = [0, 20.8];
            const fuelStrokeDasharray = (fuel.value / 100) * (fuelStrokeDasharrayMinMax[1] - fuelStrokeDasharrayMinMax[0]) + fuelStrokeDasharrayMinMax[0];
            document.querySelector(".speed-percentage .fuel").setAttribute("stroke-dasharray", `${fuelStrokeDasharray}, 100`);

            if (fuel.value <= 20) {
                fuelColor.value = "#ff0000";
            } else if (fuel.value <= 30) {
                fuelColor.value = "#dd6e14";
            }

            if (healthAmount <= 200) {
                engineColor.value = "#ff0000";
            } else if (healthAmount <= 500) {
                engineColor.value = "#FFA500";
            } else {
                engineColor.value = "#00FF00";
            }
        }

        function ShowWeapon(bool) {
            showWeapon.value = bool;
        }

        function UpdateWeaponAmmo(clipAmount, bagAmount) {
            ammoClip.value = clipAmount;
            ammoBag.value = bagAmount;
        }

        function IsTalking(bool) {
            talking.value = bool;
            talkingColor.value = talking.value ? "#FFFF3E" : "#FFFFFF";
        }

        function UpdateVoiceVolume(radius) {
            voice.value = radius;
        }

        function setupEventListeners() {
            UpdateHUD = updateHudData;
            UpdateMoney = UpdateMoney;
            UpdateVehicleStats = UpdateVehicleStats;
            UpdateWeaponAmmo = UpdateWeaponAmmo;
            ShowCashAmount = ShowCashAmount;
            ShowBankAmount = ShowBankAmount;
            ShowSpeedometer = ShowSpeedometer;
            ShowWeapon = ShowWeapon;
            IsTalking = IsTalking;
            UpdateVoiceVolume = UpdateVoiceVolume;

            window.UpdateHUD = updateHudData;
            window.UpdateMoney = UpdateMoney;
            window.UpdateVehicleStats = UpdateVehicleStats;
            window.UpdateWeaponAmmo = UpdateWeaponAmmo;
            window.ShowCashAmount = ShowCashAmount;
            window.ShowBankAmount = ShowBankAmount;
            window.ShowSpeedometer = ShowSpeedometer;
            window.ShowWeapon = ShowWeapon;
            window.IsTalking = IsTalking;
            window.UpdateVoiceVolume = UpdateVoiceVolume;
        }

        onMounted(() => {
            setupEventListeners();
        });

        return {
            showAll,
            showCash,
            showBank,
            cash,
            bank,
            health,
            armor,
            voice,
            talking,
            hunger,
            thirst,
            stress,
            talkingColor,
            healthColor,
            armorColor,
            hungerColor,
            thirstColor,
            amount,
            plus,
            minus,
            showUpdate,
            speed,
            vehHealth,
            vehMaxHealth,
            acceleration,
            rpm,
            vehGear,
            fuel,
            fuelColor,
            engineColor,
            fuelgauge,
            seatbelt,
            cruise,
            showSpeedometer,
            ammoClip,
            ammoBag,
            showWeapon,
        };
    },
});

app.use(Quasar);
app.mount("#main-container");
