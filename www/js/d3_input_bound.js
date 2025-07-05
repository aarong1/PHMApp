 document.addEventListener('DOMContentLoaded', function() {
      
      setTimeout(function() {
    $('#mydiv').fadeOut('slow');
}, 4000); // <-- time in milliseconds

 setTimeout(function() {
    $('#show').fadeIn('slow');
}, 4000); // <-- time in milliseconds

        Shiny.addCustomMessageHandler('updateData', function(data) {
          createScatterPlot(data);
        });
        
        Shiny.addCustomMessageHandler('scroll', function(data) {
          console.log('scroll');
          const element = document.getElementById('outputs');
          element.scrollIntoView();   ;
        });

        function createScatterPlot(data) {
          var margin = {top: 20, right: 20, bottom: 30, left: 40},
              width = 500
              height = 250
    
          var xScale = d3.scaleLinear()
            .domain([2019, 2025])
            .range([0, width]);

          var yScale = d3.scaleLinear()
            .domain([-1, 6])
            .range([height, 0]);

          var svg = d3.select('#scatterPlot').append('svg')
            .attr('preserveAspectRatio', 'xMinYMin meet')
            .attr('viewBox', '0 0 1050 300')
            //.append('g');

            //.attr('width', 500 )
            //.attr('height', 500)
            
             // Create a tooltip div that is hidden by default:
          var tooltip = d3.select('body').append('div')
            .attr('class', 'tooltip')
            .style('background-color', '#FAF9F6')
            .style('font-size','15px')
            .style('opacity', 0);
            
          svg.selectAll('rect')
            .data(data)
            .enter()
            .append('rect')
            .attr('x', function(d) { return xScale(d.x); })
            .attr('y', function(d) { return yScale(d.y); })
            .attr('rx', 10)

            //.attr('r', 10)
            .attr('width', 30)
            .attr('height', 70)
            .call(d3.drag()
              .on('start', dragstarted)
              .on('drag', dragged)
              .on('end', dragended))
              .on('mouseover', function(event, d) {
              tooltip.transition()
                .duration(200)
                .style('opacity', .9);
              tooltip.html(' Year : ' + d.x+ '<br/>y: ' + d.y)
                .style('left', (event.pageX + 15) + 'px')
                .style('top', (event.pageY - 28) + 'px');
            })
            .on('mouseout', function(d) {
              tooltip.transition()
                .duration(500)
                .style('opacity', 0);
            });;

          function dragstarted(event, d) {
            d3.select(this).attr('fill', 'red');
            const ogx = event.x ;
            const ogy = event.y ;
          }

          function dragged(event, d) {
          
          var svg = d3.select('svg');
          svg.on('mousemove', (d) => {
            var finalx = d.clientX
            var finaly = d.clientY; });
          
           
          console.log(d)
          console.log(event)
          
           var selectedCircles = svg.selectAll('circle')
                .filter(function(d) { return d.x > event.subject.x; });

            //selectedCircles.style('fill', 'orange');
          
          }

          function dragended(event, d) {
          
           d3.select(this)//.attr('fill', 'black')
           .attr('x', d.x = xScale(event.subject.x))
           .attr('y', d.y = Math.round((yScale(event.subject.y)+event.y)/10)*10);
           
           console.log(Math.round((yScale(event.subject.y)+event.y)/10)*10);
          
          
          //var selectedCircles = svg.selectAll('circle')
            //.filter(function(d) { return d.x > event.subject.x; })
          
          //selectedCircles
            //  .style('fill', 'black')
            
            d.x = xScale.invert(d.x);
            d.y = yScale.invert(d.y);
              
            Shiny.setInputValue('drag_data', d);
            

          }
        }

        // Initial plot
        var data = JSON.parse('" , json_data , "');
        createScatterPlot(data);
      });