library(shiny)
library(htmltools)


rag_line <- function(){HTML('
<head>

  <style>
    /* Styling for the block */
    .colour-block {
    margin-block:10px;
      display: flex;
      width:100%;
      height: 20px;
      position: relative;
            gap:2px;

    }

    .colour-segment {
    border-radius:5%;
    flex:1
     
    }
    .segment-1 { background-color: lightgreen; flex:0.2;}
    .segment-2 { background-color: yellow;flex:0.05; }
    .segment-3 { background-color: orange; flex:0.05;}
    .segment-4 { background-color: #ff4741;flex:0.7; }

    /* Styling for the arrow */
    .arrow {
      width: 0;
      height: 0;
      border-left: 10px solid transparent;
      border-right: 10px solid transparent;
      border-top: 15px solid black;
      border-radius:35%;
      position: absolute;
      top: -20px; /* Position the tip of the arrow at the top of the block */
      transform: translateX(-50%);
    }
  </style>
</head>
<body>
  <div class="colour-block">
    <div class="colour-segment segment-1"></div>
    <div class="colour-segment segment-2"></div>
    <div class="colour-segment segment-3"></div>
    <div class="colour-segment segment-4"></div>
    <div class="arrow" id="arrow"></div>
  </div>

  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <script>
    // Function to position the arrow
    function setArrowPosition(percentage) {
      if (percentage < 0 || percentage > 100) {
        console.error("Percentage value must be between 0 and 100");
        return;
      }
      const blockWidth = 400; // Width of the block in pixels
      const arrowPosition = (percentage / 100) * blockWidth; // Calculate the position in pixels
      $("#arrow").css("left", `${arrowPosition}px`);
    }

    // Example usage
    setArrowPosition(10.976); // Move the arrow to 25% of the blocks width
  </script>
</body>
')
}

browsable(rag_line())
