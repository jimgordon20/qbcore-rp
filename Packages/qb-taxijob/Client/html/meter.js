let meterStarted = false;

const updateMeter = (currentFare, distanceTraveled) => {
    $("#total-price").html("$ " + currentFare.toFixed(2));
    $("#total-distance").html(distanceTraveled.toFixed(2) + " mi");
};

const resetMeter = () => {
    $("#total-price").html("$ 0.00");
    $("#total-distance").html("0.00 mi");
};

const toggleMeter = (enabled) => {
    if (enabled) {
        $(".toggle-meter-btn").html("<p>Started</p>");
        $(".toggle-meter-btn p").css({ color: "rgb(51, 160, 37)" });
    } else {
        $(".toggle-meter-btn").html("<p>Stopped</p>");
        $(".toggle-meter-btn p").css({ color: "rgb(231, 30, 37)" });
    }
};

const meterToggle = () => {
    if (!meterStarted) {
        $.post(
            "https://qb-taxijob/enableMeter",
            JSON.stringify({
                enabled: true,
            })
        );
        toggleMeter(true);
        meterStarted = true;
    } else {
        $.post(
            "https://qb-taxijob/enableMeter",
            JSON.stringify({
                enabled: false,
            })
        );
        toggleMeter(false);
        meterStarted = false;
    }
};

const openMeter = (startingPrice) => {
    $(".container").fadeIn(150);
    $("#total-price-per-100m").html("$ " + startingPrice.toFixed(2));
};

const closeMeter = () => {
    $(".container").fadeOut(150);
};

$(".container").hide();

Events.Subscribe('TOGGLE_METER_UI', (enabled, startingPrice) => {
    if (enabled) {
        openMeter(startingPrice);
    } else {
        closeMeter();
    }
})

Events.Subscribe('TOGGLE_METER_COUNTING', () => {
    meterToggle()
})

Events.Subscribe('UPDATE_METER', (currentFare, distanceTraveled) => {
    updateMeter(currentFare, distanceTraveled)
})

Events.Subscribe('RESET_METER', () => {
    resetMeter();
})