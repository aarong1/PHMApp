$(document).ready(function() {
    console.log('Clipboard manipulation funtion calledd');



    document.getElementById('copy_editor').addEventListener('click', async function() {
        console.log('Copy button clicked');

        try {
            const richContentDiv = document.getElementById('editor');

            // Create a Blob object with the div content as HTML
            const contentBlob = new Blob([richContentDiv.innerHTML],{ type: 'text/html' });
            
            delta = window.quill.getContents()
            
            console.log(contentBlob);
            console.log(delta);
            
            // Create a ClipboardItem
            const clipboardItem = new ClipboardItem({ 'text/html': contentBlob });

            // Write the ClipboardItem to the clipboard
            await navigator.clipboard.write([clipboardItem]);
            alert('Content copied to clipboard!');


            // Store the Blob content in localStorage (serialized) -will need to unserialise on retrevial
            const reader = new FileReader();
            reader.onload = function() {
                localStorage.setItem('blob_data', reader.result); // Store as Base64
                console.log('Blob (content html) to localStorage');
            };
            reader.readAsDataURL(contentBlob);
            
            localStorage.setItem("delta", JSON.stringify(window.quill.getContents()));

            // Read from clipboard and send to Shiny
            const clipboardItems = await navigator.clipboard.read();
            for (let item of clipboardItems) {
                if (item.types.includes('text/html')) {
                    const blob = await item.getType('text/html');
                    const htmlContent = await blob.text();
                    Shiny.setInputValue('clipboard_html', htmlContent, { priority: 'event' });
                }
            }
        } catch (err) {
            console.error('Failed to copy to clipboard: ', err.message);
        }
    });
});