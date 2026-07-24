#ifndef MINIQUAKE_GL_RMAIN_REDIRECT_H
#define MINIQUAKE_GL_RMAIN_REDIRECT_H

/*
Redirect only the OpenGL calls made by the pinned gl_rmain.c translation unit.
The fixture still compiles the unmodified function bodies and real Quake types;
these diagnostic entry points make their observable command stream headless.
*/

void MQ_glTranslatef (GLfloat x, GLfloat y, GLfloat z);
void MQ_glRotatef (GLfloat angle, GLfloat x, GLfloat y, GLfloat z);
void MQ_glColor3f (GLfloat red, GLfloat green, GLfloat blue);
void MQ_glColor4f (GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);
void MQ_glColor4fv (const GLfloat *values);
void MQ_glEnable (GLenum capability);
void MQ_glDisable (GLenum capability);
void MQ_glBegin (GLenum mode);
void MQ_glEnd (void);
void MQ_glTexCoord2f (GLfloat s, GLfloat t);
void MQ_glVertex3f (GLfloat x, GLfloat y, GLfloat z);
void MQ_glVertex3fv (const GLfloat *values);
void MQ_glPushMatrix (void);
void MQ_glPopMatrix (void);
void MQ_glScalef (GLfloat x, GLfloat y, GLfloat z);
void MQ_glShadeModel (GLenum mode);
void MQ_glTexEnvf (GLenum target, GLenum name, GLfloat value);
void MQ_glHint (GLenum target, GLenum mode);
void MQ_glDepthRange (GLclampd minimum, GLclampd maximum);
void MQ_glLoadIdentity (void);
void MQ_glFrustum (GLdouble left, GLdouble right, GLdouble bottom,
	GLdouble top, GLdouble near_value, GLdouble far_value);
void MQ_glMatrixMode (GLenum mode);
void MQ_glViewport (GLint x, GLint y, GLsizei width, GLsizei height);
void MQ_glCullFace (GLenum mode);
void MQ_glGetFloatv (GLenum name, GLfloat *values);
void MQ_glClear (GLbitfield mask);
void MQ_glDepthFunc (GLenum function);
void MQ_glLoadMatrixf (const GLfloat *values);
void MQ_glFinish (void);

#define glTranslatef MQ_glTranslatef
#define glRotatef MQ_glRotatef
#define glColor3f MQ_glColor3f
#define glColor4f MQ_glColor4f
#define glColor4fv MQ_glColor4fv
#define glEnable MQ_glEnable
#define glDisable MQ_glDisable
#define glBegin MQ_glBegin
#define glEnd MQ_glEnd
#define glTexCoord2f MQ_glTexCoord2f
#define glVertex3f MQ_glVertex3f
#define glVertex3fv MQ_glVertex3fv
#define glPushMatrix MQ_glPushMatrix
#define glPopMatrix MQ_glPopMatrix
#define glScalef MQ_glScalef
#define glShadeModel MQ_glShadeModel
#define glTexEnvf MQ_glTexEnvf
#define glHint MQ_glHint
#define glDepthRange MQ_glDepthRange
#define glLoadIdentity MQ_glLoadIdentity
#define glFrustum MQ_glFrustum
#define glMatrixMode MQ_glMatrixMode
#define glViewport MQ_glViewport
#define glCullFace MQ_glCullFace
#define glGetFloatv MQ_glGetFloatv
#define glClear MQ_glClear
#define glDepthFunc MQ_glDepthFunc
#define glLoadMatrixf MQ_glLoadMatrixf
#define glFinish MQ_glFinish

#endif
