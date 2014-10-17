#include <dummy_foo_AdderImpl.h>


JNIEXPORT jint JNICALL
Java_dummy_foo_AdderImpl_add(JNIEnv *env, jobject obj, jint a, jint b)
{
    return a + b;
}

JNIEXPORT jint JNICALL
Java_dummy_foo_AdderImpl_subtract(JNIEnv *env, jobject obj, jint a, jint b)
{
    return a - b;
}
