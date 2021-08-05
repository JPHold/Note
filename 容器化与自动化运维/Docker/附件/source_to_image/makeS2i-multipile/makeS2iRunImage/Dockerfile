FROM frolvlad/alpine-java:jre8.202.08-slim
COPY --from=s2i_multiple_build_image_app ./app.jar .
CMD ["java","-jar","app.jar"]
