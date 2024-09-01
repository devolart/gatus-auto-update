FROM ubuntu

WORKDIR /workspace/gatus
RUN apt update && apt install -y curl bash
COPY . .

CMD bash start.sh