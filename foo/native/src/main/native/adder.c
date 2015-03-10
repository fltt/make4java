/*
 * make4java - A Makefile for Java projects
 *
 * Written in 2015 by Francesco Lattanzio <franz.lattanzio@gmail.com>
 *
 * To the extent possible under law, the author have dedicated all
 * copyright and related and neighboring rights to this software to
 * the public domain worldwide. This software is distributed without
 * any warranty.
 *
 * You should have received a copy of the CC0 Public Domain Dedication
 * along with this software.
 * If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
 */

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
