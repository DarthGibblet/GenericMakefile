CC=g++
CFLAGS=-I.
APP_NAME=app
BUILD_DIR=build

HEADER_FILES=$(wildcard *.h) $(wildcard **/*.h)
BODY_FILES=$(wildcard *.cpp) $(wildcard **/*.cpp)

SOURCE_FILES=${HEADER_FILES} ${BODY_FILES}
BODY_BASE_NAMES=$(basename ${BODY_FILES} .cpp)
INTERMEDIATE_BASE_NAMES=$(addprefix ${BUILD_DIR}/, ${BODY_BASE_NAMES})
DEPENDENCY_FILES=$(addsuffix .d, ${INTERMEDIATE_BASE_NAMES})
OBJECT_FILES=$(addsuffix .o, ${INTERMEDIATE_BASE_NAMES})

.PHONY: build run clean depends link

build: link

run: build
	@${BUILD_DIR}/${APP_NAME}

clean:
	@rm -rvf ${BUILD_DIR}

depends: ${DEPENDENCY_FILES}

-include ${DEPENDENCY_FILES}

${BUILD_DIR}/%.o: %.cpp ${BUILD_DIR}/%.d
	@mkdir -p "$(dir $@)"
	${CC} ${CFLAGS} -c -o $@ $<

link: ${BUILD_DIR}/${APP_NAME}
	
${BUILD_DIR}/${APP_NAME}: ${DEPENDENCY_FILES} ${OBJECT_FILES}
	${CC} ${CFLAGS} -o ${BUILD_DIR}/${APP_NAME} ${OBJECT_FILES}

${BUILD_DIR}/%.d : %.cpp ${HEADER_FILES}
	@mkdir -p "$(dir $@)"
	${CC} -MM $< -MT '$${BUILD_DIR}/$(patsubst %.cpp,%.o,$<)' -MF $@
