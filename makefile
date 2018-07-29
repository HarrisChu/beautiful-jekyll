start:
	docker run -d -p 4000:4000 --name beautiful-jekyll -v "$PWD":/srv/jekyll --restart=always beautiful-jekyll:v0.1
