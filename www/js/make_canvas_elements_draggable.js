$(document).ready(function() {
  // Function to set draggable attribute on all canvas elements
  function makeCanvasDraggable() {
    $("canvas").attr("draggable", true);
    $("table").attr("draggable", true);

  };

  // Initial call to make canvases draggable

  console.log("draggable fn called");


    // Listen for open side panel   event
  $("#toggle_close").on("click", function() {
    $("canvas").attr("draggable", false);
    $("table").attr("draggable", false);
  });
  
  
  // Listen for open side panel   event
  $("#toggle_open").on("click", function() {
    makeCanvasDraggable();
    
    // Function to setup each canvas
    function setupCanvas(canvas) {
        // Add dragstart event
        canvas.addEventListener("dragstart", function(event){
             console.log('dragstart')
            const dataUrl = canvas.toDataURL("image/png");
            console.log('dragstart')

            event.dataTransfer.setData("text/plain", dataUrl);
            console.log(event.dataTransfer.getData("text/plain"));
        });
    }
    
window.setupCanvas = setupCanvas;

    // Get all canvas elements and setup them
    const canvases = document.getElementsByTagName("canvas");
    Array.from(canvases).forEach(setupCanvas);

    // Add dragover event to allow dropping
    document.getElementById("editor").addEventListener("dragover", function(event){
        event.preventDefault();
    });

    // Add drop event to insert image into Quill
    document.getElementById("editor").addEventListener("drop", function(event){
        event.preventDefault();
        const dataUrl = event.dataTransfer.getData("text/plain");
        console.log(dataUrl);
        const range = quill.getSelection();
        quill.insertEmbed(45, //range.index, 
        "image", dataUrl);
    });
    
  });
});