// General
const showUi = () => {
    $('body').removeClass('hidden');
}

const hideUi = () => {
    $('body').addClass('hidden');
}

// Options
const $options = {
    header: {
        title: $('.options-selector header h1'),
        playersCount: $('.options-selector header .players-count .value'),
    },
    slider: {
        wrapper: $('.options-selector .slider'),
        options: $('.options-selector .slider .options .scroller'),
        button: $('.options-selector .slider .slide'),
        pages: $('.options-selector .slider .slider-pages'),
    }
}
let persistentOptions = [];
let actualPage = 0;


const setOptionsSelectorName = name => {
    $options.header.title.text(name);
}

const setOptionsSelectorPlayersCount = count => {
    $options.header.playersCount.text(count);
}

const setOptions = options => {
    persistentOptions = options;
    $options.slider.options.find('.option').remove();
    options.forEach((option, index) => {

        $options.slider.options.append(`<div class="option ${index == 0 ? "selected" : ""}">
            <img src="${option.image}" alt="${option.name}" class="bg">
            <p class="name">${option.name}</p>
            <p class="votes">0</p>
        </div>`);
    });

    if (options.length > 6) {
        $options.slider.wrapper.removeClass('disabled');
        $options.slider.wrapper.find('.button.right').removeClass('disabled');


        let pages = Math.ceil((options.length - 6) / 2);

        $options.slider.pages.empty();
        for (let i = 0; i < pages + 1; i++) {
            $options.slider.pages.append(`<div class="page ${i == 0 ? "selected" : ""}"></div>`);
        }

        $('.slider .slider-pages .page').click(function () {
            let index = $(this).index();
            actualPage = index;
            let optionWidth = $options.slider.options.find('.option').outerWidth(true) + 20;
            $options.slider.options.css('transform', `translateX(${-index * optionWidth}px)`);

            $options.slider.pages.find('.page').removeClass('selected');
            $(this).addClass('selected');

            $options.slider.button.removeClass('unable');
            if (index == 0) {
                $('.slider button.slide[data-side="left"]').addClass('unable');
            } else if (index == $options.slider.pages.find('.page').length - 1) {
                $('.slider button.slide[data-side="right"]').addClass('unable');
            }
        });
    }

    $('.options .option').click(function () {
        $('.options .option').removeClass('selected');
        $(this).addClass('selected');

        let index = $(this).index();
        setSelectedOptionInfo(options[index]);

        // Call backend event (vote)

        Events.Call("ExecuteCallback", options[index].id)
    });
}

const setOptionsVotes = votes => {
    let mostVotedIndex = 0;
    votes.forEach((vote, index) => {
        if (vote == 0) return;
        if (vote > votes[mostVotedIndex]) {
            mostVotedIndex = index;
        }
        $options.slider.options.find(`.option:nth-child(${index + 1})`).addClass('voted');
        $options.slider.options.find(`.option:nth-child(${index + 1}) .votes`).text(vote);
    });

    $options.slider.options.find(`.option:nth-child(${mostVotedIndex + 1})`).addClass('winning');
}


$('.slider button.slide').click((e) => {
    if (e.target.classList.contains('unable')) return;
    let optionWidth = $options.slider.options.find('.option').outerWidth(true) + 20;
    let actualTranslate = $options.slider.options.css('transform').split(',')[4];

    let dataSide = e.target.getAttribute('data-side');

    if (dataSide == "left") {
        actualPage--;
        $options.slider.options.css('transform', `translateX(${parseInt(actualTranslate) + optionWidth}px)`);

    } else {
        actualPage++;
        $options.slider.options.css('transform', `translateX(${parseInt(actualTranslate) - optionWidth}px)`);

    }

    $options.slider.pages.find('.page').removeClass('selected');
    $options.slider.pages.find(`.page:nth-child(${actualPage + 1})`).addClass('selected');



    $options.slider.button.removeClass('unable');
    if (dataSide == "left") {
        if (actualPage == 0) {
            $('.slider button.slide[data-side="left"]').addClass('unable');
        }
    } else {
        if (actualPage == $options.slider.pages.find('.page').length - 1) {
            $('.slider button.slide[data-side="right"]').addClass('unable');
        }
    }
});

// Selected option info

const $selectedOptionInfo = {
    name: $('.selected-option .option-name'),
    description: $('.selected-option .option-description'),
    infoList: $('.selected-option .info .list'),
}

const setSelectedOptionInfo = option => {
    $selectedOptionInfo.name.text(option.name);
    $selectedOptionInfo.description.text(option.description);

    $selectedOptionInfo.infoList.empty();
    option.info.forEach(info => {
        $selectedOptionInfo.infoList.append(`<div>
            <img src="${info.icon}" alt="${info.name}" class="icon">
            <p class="name">${info.name}</p>
            <p class="value">${info.value}</p>
        </div>`);
    });
}



// Usage
const hardcodedOptions = [
    {
        id: "0",
        name: "Frontlines",
        image: "./media/gm1.png",
        description: "Step Frontlines into the boots of a battle-hardened warrior, surrounded by the chaos of war. Frontlines delivers an unparalleled FPS experience, thrusting you into meticulously crafted battlegrounds that challenge your skills and mental toughness as you navigate tough and diverse landscapes.",
        info: [
            {
                name: "rating",
                value: "90%",
                icon: "./media/icon1.svg"
            },
            {
                name: "creator",
                value: "JohnDoe",
                icon: "./media/icon2.svg"
            },
            {
                name: "players",
                value: "2 - 24",
                icon: "./media/icon3.svg"
            }
        ]
    },
    {
        id: "1",
        name: "Casino Royale",
        image: "./media/gm2.png",
        description: "Step Casino Royale into the boots of a battle-hardened warrior, surrounded by the chaos of war. Frontlines delivers an unparalleled FPS experience, thrusting you into meticulously crafted battlegrounds that challenge your skills and mental toughness as you navigate tough and diverse landscapes.",
        info: [
            {
                name: "rating",
                value: "75%",
                icon: "./media/icon1.svg"
            },
            {
                name: "creator",
                value: "JaneSmith",
                icon: "./media/icon2.svg"
            },
            {
                name: "players",
                value: "2 - 8",
                icon: "./media/icon3.svg"
            }
        ]
    },
    {
        id: "2",
        name: "Magin Valley",
        image: "./media/gm3.png",
        description: "Step Magin Valley into the boots of a battle-hardened warrior, surrounded by the chaos of war. Frontlines delivers an unparalleled FPS experience, thrusting you into meticulously crafted battlegrounds that challenge your skills and mental toughness as you navigate tough and diverse landscapes.",
        info: [
            {
                name: "rating",
                value: "88%",
                icon: "./media/icon1.svg"
            },
            {
                name: "creator",
                value: "Player123",
                icon: "./media/icon2.svg"
            },
            {
                name: "players",
                value: "4 - 16",
                icon: "./media/icon3.svg"
            }
        ]
    },
    {
        id: "3",
        name: "Scary Museum",
        image: "./media/gm4.png",
        description: "Step Scary Museum into the boots of a battle-hardened warrior, surrounded by the chaos of war. Frontlines delivers an unparalleled FPS experience, thrusting you into meticulously crafted battlegrounds that challenge your skills and mental toughness as you navigate tough and diverse landscapes.",
        info: [
            {
                name: "rating",
                value: "95%",
                icon: "./media/icon1.svg"
            },
            {
                name: "creator",
                value: "GamerX",
                icon: "./media/icon2.svg"
            },
            {
                name: "players",
                value: "1 - 12",
                icon: "./media/icon3.svg"
            }
        ]
    },
    {
        id: "4",
        name: "Wastelands",
        image: "./media/gm5.png",
        description: "Step Wastelands into the boots of a battle-hardened warrior, surrounded by the chaos of war. Frontlines delivers an unparalleled FPS experience, thrusting you into meticulously crafted battlegrounds that challenge your skills and mental toughness as you navigate tough and diverse landscapes.",
        info: [
            {
                name: "rating",
                value: "80%",
                icon: "./media/icon1.svg"
            },
            {
                name: "creator",
                value: "CreativeGamer",
                icon: "./media/icon2.svg"
            },
            {
                name: "players",
                value: "2 - 20",
                icon: "./media/icon3.svg"
            }
        ]
    },
    {
        id: "5",
        name: "Freeroam",
        image: "./media/gm6.png",
        description: "Step Freeroam into the boots of a battle-hardened warrior, surrounded by the chaos of war. Frontlines delivers an unparalleled FPS experience, thrusting you into meticulously crafted battlegrounds that challenge your skills and mental toughness as you navigate tough and diverse landscapes.",
        info: [
            {
                name: "rating",
                value: "92%",
                icon: "./media/icon1.svg"
            },
            {
                name: "creator",
                value: "SuperPlayer",
                icon: "./media/icon2.svg"
            },
            {
                name: "players",
                value: "2 - 16",
                icon: "./media/icon3.svg"
            }
        ]
    }, {
        id: "6",
        name: "Frontlines",
        image: "./media/gm1.png",
        description: "Step Frontlines into the boots of a battle-hardened warrior, surrounded by the chaos of war. Frontlines delivers an unparalleled FPS experience, thrusting you into meticulously crafted battlegrounds that challenge your skills and mental toughness as you navigate tough and diverse landscapes.",
        info: [
            {
                name: "rating",
                value: "90%",
                icon: "./media/icon1.svg"
            },
            {
                name: "creator",
                value: "JohnDoe",
                icon: "./media/icon2.svg"
            },
            {
                name: "players",
                value: "2 - 24",
                icon: "./media/icon3.svg"
            }
        ]
    },
    {
        id: "7",
        name: "Casino Royale",
        image: "./media/gm2.png",
        description: "Step Casino Royale into the boots of a battle-hardened warrior, surrounded by the chaos of war. Frontlines delivers an unparalleled FPS experience, thrusting you into meticulously crafted battlegrounds that challenge your skills and mental toughness as you navigate tough and diverse landscapes.",
        info: [
            {
                name: "rating",
                value: "75%",
                icon: "./media/icon1.svg"
            },
            {
                name: "creator",
                value: "JaneSmith",
                icon: "./media/icon2.svg"
            },
            {
                name: "players",
                value: "2 - 8",
                icon: "./media/icon3.svg"
            }
        ]
    },
    {
        id: "8",
        name: "Magin Valley",
        image: "./media/gm3.png",
        description: "Step Magin Valley into the boots of a battle-hardened warrior, surrounded by the chaos of war. Frontlines delivers an unparalleled FPS experience, thrusting you into meticulously crafted battlegrounds that challenge your skills and mental toughness as you navigate tough and diverse landscapes.",
        info: [
            {
                name: "rating",
                value: "88%",
                icon: "./media/icon1.svg"
            },
            {
                name: "creator",
                value: "Player123",
                icon: "./media/icon2.svg"
            },
            {
                name: "players",
                value: "4 - 16",
                icon: "./media/icon3.svg"
            }
        ]
    },
];

const hardcodedVotes = [0, 2, 1, 1, 0, 0, 0, 0];

setOptionsVotes(hardcodedVotes);

// showUi();

Events.Subscribe("OpenSelectMenu", function (options, title, playerscount) {
    showUi();
    setOptionsSelectorName(title)
    setOptionsSelectorPlayersCount(playerscount);
    setOptions(options)
})

Events.Subscribe("CloseSelectMenu", function () {
    hideUi()
})