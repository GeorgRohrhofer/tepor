FROM eclipse-temurin:25-jdk-alpine

RUN apk add --no-cache curl maven bash

RUN addgroup -S velocity && adduser -S velocity -G velocity

WORKDIR /velocity
RUN mkdir -p plugins

RUN curl -fSL "https://fill-data.papermc.io/v1/objects/ef1a852bfae7397e84907837925e7ad21c6312066290edaae401b77f6f423ac3/velocity-3.4.0-SNAPSHOT-558.jar" \
     -o /velocity/velocity.jar

# -------- Optional: copy plugins --------
COPY . /tepor/VelocityPlugin
WORKDIR /tepor/VelocityPlugin/velocity-plugin
RUN mvn clean package
RUN cp target/*.jar /velocity/plugins/
WORKDIR /velocity

# -------- Permissions --------
RUN chown -R velocity:velocity /velocity

USER velocity

# -------- Expose default Velocity port --------
EXPOSE 25577

# -------- Start Velocity --------
CMD ["java", "-Xms256M", "-Xmx512M", "-jar", "velocity.jar"]

