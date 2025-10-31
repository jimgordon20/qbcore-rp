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
        const voice = ref(5);
        const talking = ref(false);
        const onRadio = ref(false);
        // Color properties
        const talkingColor = ref("#FFFFFF");
        const healthColor = ref("#3FA554");
        const armorColor = ref("#326dbf");
        const hungerColor = ref("#dd6e14");
        const thirstColor = ref("#1a7cad");
        const stressColor = ref("#dc143c");

        function formatMoney(value) {
            const formatter = new Intl.NumberFormat("en-US", {
                style: "currency",
                currency: "USD",
                minimumFractionDigits: 0,
            });
            return formatter.format(value);
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

        function UpdateMoney(data) {
            const { cashAmount, bankAmount, changeAmount, isMinus, type } = data;
            amount.value = formatMoney(changeAmount);
            plus.value = false;
            minus.value = false;

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

        function IsTalking(bool) {
            talking.value = bool;
            talkingColor.value = talking.value ? "#FFFF3E" : "#FFFFFF";
        }

        function UpdateVoiceVolume(radius) {
            voice.value = radius;
        }

        function OnRadio(bool) {
            onRadio.value = bool;
        }

        onMounted(() => {
            window.addEventListener("message", function (event) {
                if (!event.data || !event.data.name) return;

                switch (event.data.name) {
                    case "UpdateHUD":
                        updateHudData(event.data.args[0]);
                        break;
                    case "UpdateMoney":
                        UpdateMoney(event.data.args[0]);
                        break;
                    case "ShowCashAmount":
                        ShowCashAmount(event.data.args[0]);
                        break;
                    case "ShowBankAmount":
                        ShowBankAmount(event.data.args[0]);
                        break;
                    case "onRadio":
                        OnRadio(event.data.args[0]);
                        break;
                    case "IsTalking":
                        IsTalking(event.data.args[0]);
                        break;
                    case "UpdateVoiceVolume":
                        UpdateVoiceVolume(event.data.args[0]);
                        break;
                }
            });
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
            onRadio,
            hunger,
            thirst,
            stress,
            talkingColor,
            healthColor,
            armorColor,
            hungerColor,
            thirstColor,
            stressColor,
            amount,
            plus,
            minus,
            showUpdate,
        };
    },
});

app.use(Quasar);
app.mount("#main-container");
