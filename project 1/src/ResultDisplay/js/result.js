var result = [];
var url_result = 'result.json';
var flag = false;

var draw = function(value, node)
{
    if(value == "none" || node == 0)
	{
		alert("Error: search info not found!");
		return;
	}
	
	if(value == "all")
	{
	    draw("temperature", node);
		draw("humidity", node);
		draw("light", node);
		return;
	}
	
	if(node == 3)
	{
	    draw(value, 1);
		draw(value, 2);
		return;
	}
	
	var context = $("#myCanvas")[0].getContext("2d");
	
	if(value == "temperature" && node == 1)
	{
		for(var i = 0; i < 999; i++)
		{
			context.strokeStyle='#F00';
			context.lineWidth=1;
			context.beginPath();
			context.moveTo(i, 500-8*parseFloat(result[i].temperature));
			context.lineTo(i+1, 500-8*parseFloat(result[i+1].temperature));
			context.stroke();
			context.closePath();
		}
		return;
	}
	
	if(value == "temperature" && node == 2)
	{
		for(var i = 1000; i < 1999; i++)
		{
			context.strokeStyle='#0FF';
			context.lineWidth=1;
			context.beginPath();
			context.moveTo(i-1000, 500-8*parseFloat(result[i].temperature));
			context.lineTo(i+1-1000, 500-8*parseFloat(result[i+1].temperature));
			context.stroke();
			context.closePath();
		}
		return;
	}
	
	if(value == "humidity" && node == 1)
	{
		for(var i = 0; i < 999; i++)
		{
			context.strokeStyle='#0F0';
			context.lineWidth=1;
			context.beginPath();
			context.moveTo(i, 500-4*parseFloat(result[i].humidity));
			context.lineTo(i+1, 500-4*parseFloat(result[i+1].humidity));
			context.stroke();
			context.closePath();
		}
		return;
	}
	
	if(value == "humidity" && node == 2)
	{
		for(var i = 1000; i < 1999; i++)
		{
			context.strokeStyle='#F0F';
			context.lineWidth=1;
			context.beginPath();
			context.moveTo(i-1000, 500-4*parseFloat(result[i].humidity));
			context.lineTo(i+1-1000, 500-4*parseFloat(result[i+1].humidity));
			context.stroke();
			context.closePath();
		}
		return;
	}
	
	if(value == "light" && node == 1)
	{
		for(var i = 0; i < 999; i++)
		{
			context.strokeStyle='#00F';
			context.lineWidth=1;
			context.beginPath();
			context.moveTo(i, 500-25*parseFloat(result[i].light));
			context.lineTo(i+1, 500-25*parseFloat(result[i+1].light));
			context.stroke();
			context.closePath();
		}
		return;
	}
	
	if(value == "light" && node == 2)
	{
		for(var i = 1000; i < 1999; i++)
		{
			context.strokeStyle='#FF0';
			context.lineWidth=1;
			context.beginPath();
			context.moveTo(i-1000, 500-25*parseFloat(result[i].light));
			context.lineTo(i+1-1000, 500-25*parseFloat(result[i+1].light));
			context.stroke();
			context.closePath();
		}
		return;
	}
}

var update = function()
{
	var c = $("#myCanvas")[0];
	c.width = c.width; //清除画布
	
	var context = c.getContext("2d");
	context.strokeStyle='#000';
	context.lineWidth=1;
	context.beginPath();
	context.moveTo(0, 0);
	context.lineTo(0, 500);
	context.lineTo(1000, 500);
	context.stroke();
	context.closePath();
    
	var value_type = $("#value_type");
	var value = "none";
	switch(value_type.val()){
		case "全部" : 
			value = "all";
			break;
		case "温度" :
			value = "temperature";
			break;
		case "湿度" :
			value = "humidity";
			break;
		case "亮度" :
			value = "light";
			break;
		default :
			break;
	}
	
	var node_number = $("#node_number");
	var node = 0;
	switch(node_number.val()){
		case "全部" : 
			node = 3;
			break;
		case "节点1" :
			node = 1;
			break;
		case "节点2" :
			node = 2;
			break;
		default :
			break;	
	}
	
	draw(value, node);
}

var processData_result = function (data)
{
	for(var i = 0; i < data.result.length; i++) //将读到的评论json文件存储到本地
	{
		result[parseInt(data.result[i].sequence, 10) - 1 + (parseInt(data.result[i].nodeid, 10) - 1) * 1000] = data.result[i];
	}
	if(flag == -1) //获取缓存，显示上次浏览的图片
	{
		update();
		flag = true;
	}
}

var handler_result = function ()
{
	if (this.readyState == 4)
	{
		if (this.status == 200) //若读到合格的json文件
		{
			try
			{
				var json = JSON.parse(this.responseText);
				processData_result(json);
			}
			catch(ex)
			{
				console.log(ex.message);
			}
		}
	}
}

var ajax_result = function () //利用ajax获取json文件
{
	var client = new XMLHttpRequest();
	client.onreadystatechange = handler_result;
	client.open('GET', url_result);
	client.send();
}

window.onload = function(){ajax_result();}();