library(shiny)

animate_text <- function( ){
  
  div(class="wrapper",
      
      
        HTML('<!-- blank characters 
             https://www.quora.com/How-do-you-insert-an-invisible-character-in-HTML -->',
          span(class="word wisteria", 'Population&nbsp; Health&nbsp; Model'),
          span(class="word belize", 'Atrial&nbsp; Fibrillation&nbsp; Use&nbsp; Case'),
          span(class="word pomegranate", 'Economic&nbsp; Analysis')
        ),
  tags$head(tags$script("
  // app.js

let words = document.getElementsByClassName('word')

let wordArray = []; //will store arrays of letters for each word
let currentWord = 0; //will store the index of the currently displayed word;


words[currentWord].style.opacity = 1;


const splitLetters = word => {
    let content = word.innerText;
    word.innerText = '';
    let letters = [];
    for (let i = 0; i < content.length; i++) {
      let letter = document.createElement('span');
      letter.className = 'letter';
      letter.innerText = content.charAt(i);
      word.appendChild(letter);
      letters.push(letter);
    }
    wordArray.push(letters);
}

for (let i = 0; i < words.length; i++) {
    splitLetters(words[i]);
  }

  const animateLetterOut = (cw, i) => { 
    setTimeout(function() {
          cw[i].className = 'letter out';
    }, i*80);
  }
  
  const animateLetterIn = (nw, i) => {
    setTimeout(function() {
          nw[i].className = 'letter in';
    }, 340+(i*80)); // delay of 340, so that new letters ('design') start falling down once the first animation is completed. 
}

const changeWord = () => {
    let cw = wordArray[currentWord]; // wordArray[0] gives us: [c,o,d,e]  
    let nw = currentWord == words.length-1 ? wordArray[0] : wordArray[currentWord+1]; // evals to wordArray[1] and gives us: [d,e,s,i,g,n] 
  
    for (let i = 0; i < cw.length; i++) {
      animateLetterOut(cw, i); // called for each letter of [c,o,d,e] with different i values, so we have a delay between each letter when they fade out.
    }
    
    for (let i = 0; i < nw.length; i++) {
      //for each letter inside [d,e,s,i,g,n]
      nw[i].className = 'letter behind'; //we set initial position to the top 
      nw[0].parentElement.style.opacity = 1; //we set the opacity to 1, but currently invisible due to overlow hidden. 
      animateLetterIn(nw, i); //animates each letter as if they fall down from top.
    }
    //update currentWord index.
    currentWord = (currentWord == wordArray.length-1) ? 0 : currentWord+1;
  }

  // Call the function, sit back and enjoy the show!

setTimeout(changeWord, 4000); //initial call
//changeWord(); //initial call'
    
  )"),
  tags$style('/* styles.css */


/* Base setup */
@import url(//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css);
@import url(https://fonts.googleapis.com/css?family=Open+Sans:600);


body {
  font-family: "Open Sans", sans-serif;
  font-weight: 600;
  font-size: 2rem;
  display: grid;
  place-items: center;
  min-height: 100vh;
  padding: 0;
  box-sizing: border-box;
  margin: 0;
  background-color: #00070d;
}

p {
    display: inline-block;
    vertical-align: top;
    margin: 0;
  }
  
  .word {
    position: absolute; /* makes words stack on top of each other */
    opacity: 0;
    left: 50%;
    transform: translateX(-50%);
    text-transform: uppercase;
  }
  
  .wisteria {
    color: #8e44ad;
  }
  
  .belize {
    color: #2980b9;
  }

  .pomegranate {
    color: #ffffff;
  }

  .letter {
    display: inline-block;
    transform-origin: 50% 50% 25px;
  }
  
  
  .letter.out {
    transform: rotateX(90deg);
    transition: transform 0.32s cubic-bezier(0.55, 0.055, 0.675, 0.19);
  }
  
  
  .letter.behind {
    transform: rotateX(-90deg);
  }
  
  
  .letter.in {
    transform: rotateX(0deg);
    transition: transform 0.38s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  }')
  ))
}

browsable(animate_text())



ui <- div(animate_text())
server <- function(input,ouput){}
shinyApp(ui = ui, server = server)

 #'<!-- blank characters  :https://www.quora.com/How-do-you-insert-an-invisible-character-in-HTML -->',
changing_words <- function(){
  div(
   div(class="wrapper",
        p(
          span(class="word wisteria", 'Population Health Model'),
          span(class="word belize", 'Atrial Fibrillation Use Case'),
          span(class="word pomegranate", 'EconomicAnalysis')
        )
      )
   )
}

browsable(changing_words())

