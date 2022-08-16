
1. 生命周期函数，不能使用this
是可以的
```
this.$el
this.$data
this.msg
```

2. v-xxx指令，是不是跟html原生，合并
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

3、v-bind:xxx,是不是可以缩写为:xxx

4、一旦vue语法报错，会导致vue的编译功能失效
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

5、解决列表循环下，就地复用，导致元素错乱
input元素（未采用:value指令进行初始赋值）会有这个问题


6、注意列表循环下，如果input采用:value指令进行初始赋值,你修改了input值，在删除数组数据后，触发dom响应，修改的值会恢复成初始值
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<title></title>
		<script src="../vue.js"></script>
	</head>
	<body>
		<div id="app">
			<ul>
				<li v-for="(item,index) in list" :key="index">
					{{ index }} = {{ item.key1 }}
					<input type="text"></input>
					<!-- 这种就不会有问题 -->
					<input type="text" :value="item.key1"></input>
					<button @click="onDelete(index)">delete</button>

				</li>
			</ul>
			<ul>
				<li v-for="(item,key) in object">
					{{ key }} ：{{ item }}
				</li>
			</ul>
		</div>
	</body>
	<script>
		var vm = new Vue({
			el: '#app',
			data: {
				list: [{
						'key1': "value1"
					},
					{
						'key1': "value2"
					},
					{
						'key1': "value3"
					}
				],
				object: {
					'key3': "value5",
					"key4": "value6"
				}
			},
			methods:{
				onDelete: function(index){
					vm.list.splice(index, 1);
				}
			}
		});
		
	</script>
</html>



------------------------------------------------------------ 原理
1、组件化（注册component）
https://cn.vuejs.org/v2/guide/#%E4%B8%8E%E8%87%AA%E5%AE%9A%E4%B9%89%E5%85%83%E7%B4%A0%E7%9A%84%E5%85%B3%E7%B3%BB

与web组件规范的自定义元素差不多，但以下不同：
--- Web Components 规范目前支持这些浏览器：Safari 10.1+、Chrome 54+ 和 Firefox 63+ 
-- Vue 组件不需要任何 polyfill（腻子，有些古老浏览器不支持某个api，但我们为了不改变写法，需要写一个库来支撑），并且在所有支持的浏览器 (IE9 及更高版本) 中表现是一致
-- Vue 组件也可以包装于原生自定义元素之内。

vue组件比自定义元素的优势：
-- 跨组件数据流
-- 自定义事件通信以及构建工具集成
-- 通过cli，可将vue组件转换成自定义元素