let dash = 0;
let interval = null


Events.Subscribe("interact:pressed", function(){
    if (dash == 0){
        document.getElementById("circle").setAttribute("stroke-dasharray", "0, 100");
        document.getElementById("circle").setAttribute("stroke", "rgba(233, 233, 233, 0.7)");
        interval = setInterval(function() {
            let e = document.getElementById("circle");
            dash = e.getAttribute("stroke-dasharray");
            dash = dash.split(",");
            dash[0] = parseInt(dash[0]) + 1;
            dash[1] = parseInt(dash[1]) + 1;
            e.setAttribute("stroke-dasharray", dash[0] + ", 100");
            if (dash[0] == 100){
                endInteract();
            }
        }, 15);
    }
});

Events.Subscribe("interact:released", function(){    
    document.getElementById("circle").setAttribute("stroke-dasharray", "0, 100");
    document.getElementById("circle").setAttribute("stroke", "transparent");
    clearInterval(interval);
    dash = 0;
});

Events.Subscribe("interact:show", function(state, text){
    let e = document.getElementsByClassName("screen")[0];
    let eText = document.getElementById("interaction-text");
    e.style.opacity = state ? 1 : 0;
    eText.innerText = text;
});

function endInteract(){
    let e = document.getElementsByClassName("screen")[0];
    e.style.opacity = 0;

    document.getElementById("circle").setAttribute("stroke-dasharray", "0, 100");
    document.getElementById("circle").setAttribute("stroke", "transparent");
    clearInterval(interval);
    dash = 0;
    
    Events.Call("interact:complete");
}