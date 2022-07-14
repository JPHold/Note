
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






7、条件渲染
v-if和v-show都可以

v-if配合v-else-if、v-else使用，但有点奇怪，后面两个命令不是在v-if命令内部，而是同级

v-show是通过修改内联样式：display属性，为false则不展示

两者的应用场景：
v-if才是真正的条件渲染，会销毁或重建子组件和事件监听；不适合频繁切换

v-show是一开始就渲染出来，只是赋予display属性，隐藏或展示，只需修改该属性，不会重建；适合频繁切换

8、列表循环
支持数组和对象

得注意删除元素后，“就地更新”，目前发现两个问题（vue3和vue2都存在）：

1. input未采用:value指令，来填充值（手动输入），删除数组中，中间某个位置的数据，会导致未加入vue响应控制的元素错位
官方原话如下（非常难懂）：
> 当 Vue 正在更新使用 v-for 渲染的元素列表时，它默认使用“就地更新”的策略。如果数据项的顺序被改变，Vue 将不会移动 DOM 元素来匹配数据项的顺序，而是就地更新每个元素，并且确保它们在每个索引位置正确渲染。这个类似 Vue 1.x 的 track-by="$index"。
这个默认的模式是高效的，但是只适用于不依赖子组件状态或临时 DOM 状态 (例如：表单输入值) 的列表渲染输出。

提到就地更新、如果数据项的顺序被改变，Vue 将不会移动 DOM 元素来匹配数据项的顺序，而是就地更新每个元素。

以数组:[1,2,3]，分别对应input值：value1、value2、value3为例，删除2位置的数据，变成[1,3]；跟原来的数组一一对比，1和1没变化，不更新、2和3不同，需更新、3和undefined不同，要删除3
-- 2和3不同，更新为3，但因为input元素没加vue控制，因此不动，为vlaue2
-- 3和undefined不同，要删除3，删掉3

执行这两步后，发现3对应的input值是value2，本应该是value3才对

网上是另一个词：就地复用（没有变化，就直接复用）

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
				<li v-for="(item,index) in list">
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

所以需要增加一个标识，标识删除的是哪个。用到:key=""，会重新排序

资料：https://www.zhihu.com/question/61064119

2. 注意列表循环下，如果input采用:value指令进行初始赋值,你修改了input值，在删除数组数据后，触发dom响应，修改的值会恢复成初始值
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


9、事件绑定
指令是on:xxx事件
支持直接在指令写js、也可以调用函数
支持修饰符，对事件类型的分类处理

10、v-model双向绑定
{{ xxx }}和v-model所在元素会同时相应，比如
<input type="text" v-model="inputText" placeholder="text" />
<input type="text" v-model="inputText" placeholder="text" />
<p>{{ inputText }}</p>

支持text、textarea、radio、checkbox等

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