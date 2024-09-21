FROM  whicha/ubuntu2204:base-latest

# Cling installation
USER root

WORKDIR /opt

RUN apt-get update && apt-get install -y \
    cmake \
    astyle \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --branch cling-latest --single-branch --depth 1 https://github.com/root-project/llvm-project.git \
  && git clone --single-branch --depth 1 https://github.com/root-project/cling.git cling-src \
  && mkdir -p cling && cd cling \
  && cmake -DCMAKE_INSTALL_PREFIX=install -DLLVM_EXTERNAL_PROJECTS=cling -DLLVM_EXTERNAL_CLING_SOURCE_DIR=../cling-src/ -DLLVM_ENABLE_PROJECTS="clang" -DLLVM_BUILD_TOOLS=OFF -DLLVM_TARGETS_TO_BUILD="host;NVPTX" -DCMAKE_BUILD_TYPE=Release ../llvm-project/llvm \
  && cmake --build . -j$(nproc) --config Release && cmake --build . -j$(nproc) --target install \
  && cd .. \
  && rm -rf llvm-project \
  && mv cling/install cling-install \
  && rm -rf cling \
  && mv cling-install cling

ENV PATH="/opt/cling/bin:$PATH"

RUN mkdir -p cling-src/tools/Jupyter/kernel/cling-cpp2b \
  && echo "{\n  \"display_name\": \"C++2b\",\n  \"argv\": [\n      \"jupyter-cling-kernel\",\n      \"-f\",\n      \"{connection_file}\",\n      \"--std=c++2b\"\n  ],\n  \"language\": \"C++\"\n}\n" > cling-src/tools/Jupyter/kernel/cling-cpp2b/kernel.json \
  && mkdir -p cling-src/tools/Jupyter/kernel/cling-cpp20 \
  && echo "{\n  \"display_name\": \"C++20\",\n  \"argv\": [\n      \"jupyter-cling-kernel\",\n      \"-f\",\n      \"{connection_file}\",\n      \"--std=c++20\"\n  ],\n  \"language\": \"C++\"\n}\n" > cling-src/tools/Jupyter/kernel/cling-cpp20/kernel.json \
  && rm -r cling-src/tools/Jupyter/kernel/cling-cpp1z \
  && sed -i "s/\['c++11', 'c++14', 'c++1z', 'c++17'\]/\['c++11', 'c++14', 'c++17', 'c++20', 'c++2b'\]/g" cling-src/tools/Jupyter/kernel/clingkernel.py \
  && sed -i 's/C++ standard to use, either c++17, c++1z, c++14 or c++11/C++ standard to use, either c++2b, c++20, c++17, c++14 or c++11/g' cling-src/tools/Jupyter/kernel/clingkernel.py \
  && sed -i 's/register the kernelspec for C++17\/C++1z\/C++14\/C++11/register the kernelspec for C++2b\/C++20\/C++17\/C++14\/C++11/g' cling-src/tools/Jupyter/README.md \
  && sed -i ':a;N;$!ba;s/jupyter-kernelspec install \[--user\] cling-cpp17\n    jupyter-kernelspec install \[--user\] cling-cpp1z/jupyter-kernelspec install [--user] cling-cpp2b\n    jupyter-kernelspec install [--user] cling-cpp20\n    jupyter-kernelspec install [--user] cling-cpp17/g' cling-src/tools/Jupyter/README.md

RUN cd cling-src/tools/Jupyter/kernel \
  && pip install -e . \
  && jupyter-kernelspec install cling-cpp2b \
  && jupyter-kernelspec install cling-cpp20 \
  && jupyter-kernelspec install cling-cpp17 \
  && jupyter-kernelspec install cling-cpp14 \
  && jupyter-kernelspec install cling-cpp11

# config done
ARG USERNAME=containeruser

USER $USERNAME

WORKDIR /home/$USERNAME

CMD ["/usr/bin/zsh"]
