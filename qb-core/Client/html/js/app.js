const { useQuasar } = Quasar;

const defaultConfig = {
    NotificationStyling: {
        group: true,
        position: "top-right",
        progress: true,
    },
    VariantDefinitions: {
        success: {
            classes: "success",
            icon: "done",
        },
        primary: {
            classes: "primary",
            icon: "info",
        },
        error: {
            classes: "error",
            icon: "dangerous",
        },
        police: {
            classes: "police",
            icon: "local_police",
        },
        ambulance: {
            classes: "ambulance",
            icon: "fas fa-ambulance",
        },
    },
};

const app = Vue.createApp({
    mounted() {
        window.showNotif = this.showNotif;
        window.addEventListener('message', function(event) {
            switch(event.data.name) {
                case "showNotif":
                    this.showNotif(...event.data.args);
                    break;
                case "drawText":
                    drawText(...event.data.args);
                    break;
                case "hideText":
                    hideText();
                    break;
                case "changeText":
                    changeText(...event.data.args);
                    break;
                case "keyPressed":
                    keyPressed();
                    break;
            }
        })
    },
    methods: {
        async showNotif(data) {
            const { text, length, type, caption, icon: dataIcon } = data;
            let { classes, icon } = defaultConfig.VariantDefinitions[type];

            if (dataIcon) {
                icon = dataIcon;
            }

            this.$q.notify({
                message: text,
                multiLine: text.length > 100,
                group: defaultConfig.NotificationStyling.group ?? false,
                progress: defaultConfig.NotificationStyling.progress ?? true,
                position: defaultConfig.NotificationStyling.position ?? "right",
                timeout: length,
                caption,
                classes,
                icon,
            });
        },
    },
});

app.use(Quasar, { config: {} });
app.mount("#q-app");
