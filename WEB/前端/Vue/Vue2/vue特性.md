
1、html上输出一个变量值，如果没声明该变量，是不会响应的
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<title></title>
		<script src="../vue.js"></script>
	</head>
	<body>
		<div id="app">
			{{ a }} -- {{ b }}
		</div>
	</body>
	<script>
		var data = {a: "hello"};
		var vm = new Vue({
			el: '#app',
			data: data
		});
		
		
		
		
	</script>
</html>


2、一般创建Vue对象，取名都是vm（ViewModel的意思，视图模型）





10、组件基础

--template模板
	如果有多个元素，记得使用div包裹，不然只会显示第一个元素

--emit，与外部进行通信，通过函数
	组件在html，声明@xxxEmitFunction="外部方法名"

--template模板内容，支持插槽：<slot>
	组件在html中，在html-text内容，可以加入你自定义的html内容。这样模板，加上一些独有内容，适应变化

--支持外部传递变量值
	props属性

--组件的取名
短线分隔：“-”
驼峰	


11、全局、局部注册组件

-- 10、组件基础，用的就是全局注册

-- 局部注册，依赖于vue对象
var vm = new Vue({
	el: '#app',
	components: {
		"component-local": {
			template: "<p>局部注册</p>"
		}
	}
});

12、单文件组件
因为10和11，写模板时，不好写，而且对于很长的组件编写，会很丑：\；而且不能写css

所以就有以vue为后缀的文件，每个组件一个文件，然后通过导入即可

需要用到脚手架工具

-- 安装nodejs
-- 修改npm的下载镜像地址为淘宝
-- 安装cnpm，国内的，加快下载速速的
-- 安装vue-cli
-- 安装webpack
-- 执行vue ui，用于创建moudule


-- 注意：component的vue文件，name的定义必须两个单词，不然报错
D:\2022\study\vue\vue-ui\hello\src\components\hello.vue
  7:9  error  Component name "hello" should always be multi-word  vue/multi-word-component-names

✖ 1 problem (1 error, 0 warnings)

**应该如此**
export default{
		name: 'helloTest',

13、第12点，需要熟悉命令，对npm熟悉，
所以dcloud出了了uni-app框架，更方便开发，各个客户端都适应