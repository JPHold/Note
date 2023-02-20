# 纯原生js导入
```html
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<title></title>
		<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>

	</head>
	<body>
		<div id="app">{{message}}</div>
		<script>
			const {
				createApp
			} = Vue;
			createApp({
				data() {
					return {
						message: 'Hello Vue!'
					}
				}
			}).mount('#app')
		</script>
	</body>
</html>

```

# Es模块js导入
**注意`<script type="module">`，指定是模块**
```html
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<title></title>
	</head>
	<body>
		<div id="app">{{message}}</div>
		<script type="module">
			import {createApp} from 'https://unpkg.com/vue@3/dist/vue.esm-browser.js';
			
			createApp({
				data() {
					return {
						message: 'Hello Vue!'
					}
				}
			}).mount('#app')
		</script>
	</body>
</html>

```

# 导入映射表（使用别名导入）
在[[#Es模块js导入]]基础上，将引入的js文件，抽到全局的映射表中
```html
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<title></title>
		<script type="importmap">
			{
		    "imports": {
		      "vue": "https://unpkg.com/vue@3/dist/vue.esm-browser.js"
		    }
		  }
		</script>
	</head>
	<body>
		<div id="app">{{message}}</div>
		<script type="module">
			import {
				createApp
			} from 'vue';

			createApp({
				data() {
					return {
						message: 'Hello Vue!'
					}
				}
			}).mount('#app')
		</script>
	</body>
</html>
```