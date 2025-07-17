// app.js
 document.addEventListener('DOMContentLoaded', function () {
let words = document.getElementsByClassName('word');
let wordArray = [];
let currentWord = 0;

words[currentWord].style.opacity = 1;

const splitLetters = word => {
    let content = word.textContent;
    word.textContent = '';
    let letters = [];

    for (let i = 0; i < content.length; i++) {
        let letter = document.createElement('span');
        letter.className = 'letter';

        // preserve space explicitly
        if (content.charAt(i) === ' ') {
            letter.innerHTML = '&nbsp;';
        } else {
            letter.textContent = content.charAt(i);
        }

        word.appendChild(letter);
        letters.push(letter);
    }
    wordArray.push(letters);
};

for (let i = 0; i < words.length; i++) {
    splitLetters(words[i]);
}

const animateLetterOut = (cw, i) => {
    setTimeout(() => {
        cw[i].className = 'letter out';
    }, i * 80);
};

const animateLetterIn = (nw, i) => {
    setTimeout(() => {
        nw[i].className = 'letter in';
    }, 340 + (i * 80));
};

const changeWord = () => {
    let cw = wordArray[currentWord];
    let nextIndex = currentWord === words.length - 1 ? 0 : currentWord + 1;
    let nw = wordArray[nextIndex];

    for (let i = 0; i < cw.length; i++) {
        animateLetterOut(cw, i);
    }

    for (let i = 0; i < nw.length; i++) {
        nw[i].className = 'letter behind';
        nw[0].parentElement.style.opacity = 1;
        animateLetterIn(nw, i);
    }

    currentWord = nextIndex;
};

window.changeWord = changeWord
  
});

//setTimeout(changeWord, 5000); //initial call

  // Call the function, sit back and enjoy the show!

//changeWord(); //initial call
//setInterval(changeWord, 4000); //call every 4s bac 