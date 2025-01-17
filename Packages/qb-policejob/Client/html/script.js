const openFingerprint = function () {
    document.querySelector(".fingerprint-container").style.display = "block";
    document.querySelector(".fingerprint-id").innerHTML = "Fingerprint ID<p>No result</p>";
};

const closeFingerprint = function () {
    document.querySelector(".fingerprint-container").style.display = "none";
    Events.Call("qb-policejob:client:closeFingerprint");
};

const updateFingerprint = function (data) {
    document.querySelector(".fingerprint-id").innerHTML = "Fingerprint ID<p>" + data.fingerprintId + "</p>";
};

document.querySelector(".take-fingerprint").addEventListener("click", function () {
    Events.Call("qb-policejob:client:scanFinger");
});

Events.Subscribe("qb-policejob:client:openFingerprint", openFingerprint);
Events.Subscribe("qb-policejob:client:closeFingerprint", closeFingerprint);
Events.Subscribe("qb-policejob:client:updateFingerprint", updateFingerprint);
