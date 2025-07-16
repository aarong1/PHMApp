$(document).ready(function () {
  function makeCanvasDraggable() {
    $("canvas").attr("draggable", true);
    $("table").attr("draggable", true);
  }

  function undoCanvasDraggable() {
    $("canvas").attr("draggable", false);
    $("table").attr("draggable", false);
  }

  function setupCanvas(canvas) {
    if (!canvas.dataset.dragSetup) {
      canvas.addEventListener("dragstart", function (event) {
        const dataUrl = canvas.toDataURL("image/png");
        event.dataTransfer.setData("text/plain", dataUrl);
        console.log("called setupCanvas");
      });
      canvas.dataset.dragSetup = "true"; // flag to avoid duplicate listeners
    }
  }

  // Only add this ONCE
  const editor = document.getElementById("editor");

  if (editor) {
    editor.addEventListener("dragover", function (event) {
      event.preventDefault();
    });

    editor.addEventListener("drop", function (event) {
      event.preventDefault();
      const dataUrl = event.dataTransfer.getData("text/plain");
      const range = quill.getSelection();
      if (range) {
        quill.insertEmbed(range.index, "image", dataUrl);
      }
    });
  }

  // Bind toggle_open ONCE
  $("#toggle_open").on("click", function () {
    makeCanvasDraggable();

    const canvases = document.getElementsByTagName("canvas");
    Array.from(canvases).forEach(setupCanvas);
  });

  // Bind toggle_close ONCE
  $("#toggle_close").on("click", function () {
    undoCanvasDraggable();
  });

  console.log("draggable fn called");
});