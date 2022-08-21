
* **生命周期函数，不能使用this**
是可以的
```
this.$el
this.$data
this.msg
```

* **v-xxx指令，是不是跟html原生，合并**
比如v-class跟class，会不会合并

会合并，并且相同属性冲突时，原生的优先级高
以v-class和class为例
```html
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<title></title>
		<script src="../../vue.js"></script>
	</head>
	<body>
		<div id="app">
			<div v-bind:class="'c1'" class="c2"></div>
		</div>
	</body>
	<script>
		var app = new Vue({
			el: '#app',
			data: {
				message: 'Hello Vue!',
				name: "vue"
			}
		});
	</script>
	<style>
		.c1 {
			background-color: red;
		}

		.c2 {
			width: 400px;
			height: 100px;
			background-color: yellow;
		}
	</style>
</html>
```
![[Pasted image 20220816233120.png]]

* **v-bind:xxx,是不是可以缩写为:xxx**
是的

* **v-bind和v-model的区别**
v-bind是单向绑定，v-model是双向绑定。双向绑定是修改元素的状态会反馈到变量，变量也会反馈到元素状态

以input text元素为例，绑定value属性为val1变量：`v-bind:value="val1"`
重新输入的内容，val1变量值并没有改变；修改val1变量值，会覆盖内容

以input text元素为例，绑定value属性为val1变量：`v-model:value="val1"
重新输入的内容，val1变量值有改变；修改val1变量值，会覆盖内容
```html
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<title></title>
		<script src="../../vue.js"></script>
	</head>
	<body>
		<div id="app">
			<input type="text" v-bind:value="val1"/>
			<input type="text" :value="val2"/>
			<input type="text" v-model:value="val3"/>
		</div>
	</body>
	<script>
		var app = new Vue({
			el: '#app',
			data: {
				val1: 'value1',
				val2: 'value2',
				val3: 'value3'
			}
		});
	</script>
</html>
```

* **一旦vue语法报错，会导致vue的编译功能失效**
```html
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<title></title>
		<script src="../vue.js"></script>
	</head>
	<body>
		<div id="app">
			<p v-if="type === 'A'">A</p>
			<p v-else-if="type === 'B'">B</p>
			<p v-else-if="type === 'C'">C</p>
			<p v-else>not A/B/C</p>
		</div>
	</body>
	<script>
		var app = new Vue({
		  el: '#app',
		  data: {
		    type: A
		  }
		});
		
	</script>
</html>
```


* **组件化（注册component）与web组件化的区别**
[官方文档](https://v2.cn.vuejs.org/v2/guide/#%E4%B8%8E%E8%87%AA%E5%AE%9A%E4%B9%89%E5%85%83%E7%B4%A0%E7%9A%84%E5%85%B3%E7%B3%BB)

与web组件规范的自定义元素差不多，但以下不同：
1. Web Components 规范目前支持这些浏览器：Safari 10.1+、Chrome 54+ 和 Firefox 63+ ，并不是所有浏览器都实现该规范
2. Vue 组件不需要任何 polyfill（意思是说有些古老浏览器不支持某个api，但我们为了不改变写法，需要写一个库来支撑，称为腻子），支持更多的浏览器 (IE9 及更高版本) ，他们的表现是一致
3. Vue 组件提供了Web Components所不具备的一些重要功能，**最突出的是跨组件数据流、自定义事件通信以及构建工具集成。**
4. Vue 组件也可以包装于原生自定义元素之内
5. Vue CLI支持将vuezu'j

vue组件比自定义元素的优势：
-- 跨组件数据流
-- 自定义事件通信以及构建工具集成
-- 通过cli，可将vue组件转换成自定义元素